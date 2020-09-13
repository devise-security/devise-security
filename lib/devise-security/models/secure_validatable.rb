# frozen_string_literal: true

require_relative 'compatibility'
require_relative '../validators/password_complexity_validator'

module Devise
  module Models
    # {SecureValidatable} adds additional validations for better security.
    # @note depends on database_authenticatable
    #
    # == Validations
    #
    # === Unique login
    #
    # Verifies that the first +authentication_key+ is unique (scoped by any
    # additional keys). This respects the +Devise.case_sensitive_keys+
    # configuration.  This validation is skipped if the model already declares a
    # +validates_uniqueness_of+ validator on the first +authentication_key+.
    # @note You should ensure that there is a unique index on +login_attribute+
    #   to avoid race conditions.
    #
    # === Email validation
    #
    # If the model requires an email address (i.e, +email_required?+ returns
    # +true+), then the email address is verified to be present and unique.
    #
    # Additional email validation configs can be set by configuring
    # `Devise.email_validation`, but it is probably clearer and less error prone
    # to just define these validations directly in your models due to the
    # variety of available email validation gems.
    #
    # === Password Presence
    #
    # Ensures that the +password+ is set for any model where
    # +password_required?+ returns +true+
    #
    # === Password Complexity
    #
    # @note only enforced if +password_required?+ is +true+
    #
    # Enforces password complexity requirements as described in
    # {DeviseSecurity::PasswordComplexityValidator}. The global configurations
    # can be overridden at the class or instance level by defining a method
    # called `password_complexity` that returns a {Hash} with the appropriate
    # configurations.
    #
    # === Password Length
    #
    # @note only enforced if +password_required?+ is +true+
    #
    # Ensures that the +password+ is of the configured length. The length can be
    # passed as part of the devise configuration or overridden at a class or
    # instance level by implementing a +password_length+ method that returns a
    # +Range+.
    #
    # === Password re-use
    #
    # @note only enforced if +password_required?+ is +true+
    #
    # Disallows re-using current password when changing the password.  This
    # validation is disabled if the {PasswordArchivable} module is used because
    # it results in redundant validation failures.
    #
    # == Options
    #
    # {SecureValidatable} adds the following options to the +devise+
    # declaration:
    #
    # * +password_complexity+: descriptor of the minimum character classes
    #   required for password complexity, i.e.:
    #     { digits: 1, lower: 1, upper: 1, symbol 1}
    # * +email_validation+: a Hash of validation options to be passed to the
    #   email validator
    # * +password_length+: a +Range+ expressing password length. Defaults from
    #   devise
    #
    module SecureValidatable
      extend ActiveSupport::Concern
      include Devise::Models::Compatibility

      included do |base|
        assert_secure_validations_api!(base)

        devise :database_authenticatable

        already_validated_email = false

        # login attribute should be unique
        unless has_uniqueness_validation_of_login?
          # Only perform uniqueness check when the login attribute is dirty so
          # we can avoid hitting the database unnecessarily.
          if defined?(will_save_change_to_attribute?)
            validates login_attribute, uniqueness: {
              scope: authentication_keys[1..-1],
              case_sensitive: !case_insensitive_keys.include?(login_attribute),
            }, if: -> { will_save_change_to_attribute?(self.class.login_attribute) }
          # `will_save_change_to_attribute?` was added in Rails 5.1
          # We can remove this `else` when support is dropped
          else
            validates login_attribute, uniqueness: {
              scope: authentication_keys[1..-1],
              case_sensitive: !case_insensitive_keys.include?(login_attribute),
            }
          end

          already_validated_email = login_attribute.to_s == 'email'
        end

        # Don't do these validations if the core :validateable is enabled
        unless devise_validation_enabled?
          # Validate that the email address is not blank if +email_required?+ is +true+
          validates :email, presence: true, if: :email_required?
          unless already_validated_email
            # Validates uniqueness of email if it has unsaved changes
            validates :email, uniqueness: true, allow_blank: true, if: :email_changed?
          end

          # Validates that a password is set if +password_required?+ is +true+
          validates :password, presence: true, confirmation: true, if: :password_required?

          # Validate password length requirements
          validate if: :password_required? do |record|
            validates_with ActiveModel::Validations::LengthValidator,
                           attributes: :password,
                           in: record.password_length
          end
        end

        # validate the email address
        # see https://github.com/devise-security/devise-security/blob/master/README.md#e-mail-validation
        validates :email, email: email_validation if email_validation

        # Check password complexity requirements
        validate if: :password_required? do |record|
          validates_with DeviseSecurity::PasswordComplexityValidator,
                         attributes: :password,
                         constraints: record.password_complexity
        end

        # don't allow user to change the password back to the same one
        validate :current_equal_password_validation,
                 if: ->(record) { record.devise_modules.include?(:database_authenticatable) },
                 unless: ->(record) { record.devise_modules.include?(:password_archivable) }
      end

      # Checks whether a password is needed or not. For validations only.
      # Passwords are always required if it's a new record, or if the password
      # or confirmation are being set somewhere.
      #
      # @return [Boolean]
      def password_required?
        !persisted? || !password.nil? || !password_confirmation.nil?
      end

      # Requires an +email+ attribute to be defined
      #
      # @return [Boolean]
      def email_required?
        true
      end

      # Password complexity configurations for an instance of this class,
      # defaults to the class method. Override this for more fine-grained
      # control of complexity configurations based on instance attributes.
      #
      # @return [Hash]
      def password_complexity
        self.class.password_complexity
      end

      # Password length requirements. Override this at the class or instance
      # level to override global configurations.
      #
      # @return [Range]
      def password_length
        self.class.password_length
      end

      # Email validation options. Override this at the class or instance level
      # to override global configurations.
      #
      # @return [Hash] email validation options
      def email_validation
        self.class.email_validation
      end

      private

      def current_equal_password_validation
        return if new_record? || !will_save_change_to_encrypted_password? || password.blank?

        dummy = self.class.new(encrypted_password: encrypted_password_was).tap do |user|
          user.password_salt = password_salt_was if respond_to?(:password_salt)
        end
        errors.add(:password, :equal_to_current_password) if dummy.valid_password?(password)
      end

      class_methods do
        Devise::Models.config(self, :password_complexity, :password_length, :email_validation)

        def assert_secure_validations_api!(base)
          raise "Could not use SecureValidatable on #{base}" unless base.respond_to?(:validates)
        end

        def has_uniqueness_validation_of_login?
          validators.any? do |validator|
            validator_orm_klass = DEVISE_ORM == :active_record ? ActiveRecord::Validations::UniquenessValidator : ::Mongoid::Validatable::UniquenessValidator
            validator.is_a?(validator_orm_klass) && validator.attributes.include?(login_attribute)
          end
        end

        def login_attribute
          authentication_keys[0]
        end

        def devise_validation_enabled?
          devise_modules.include?(:validateable)
        end
      end
    end
  end
end
