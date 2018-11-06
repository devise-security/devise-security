# frozen_string_literal: true

require_relative 'compatibility'
require_relative '../validators/password_complexity_validator'

module Devise
  module Models
    # SecureValidatable adds additional validations for better security.
    # @note depends on database_authenticatable
    #
    # == Validations
    # === Unique login
    # Verifies that the first +authentication_key+ is unique (scoped by any
    # additional keys). This respects the +Devise.case_sensitive_keys+
    # configuration.  This validation is skipped if the model already declares a
    # +validates_uniqueness_of+ validator on the first +authentication_key+.
    #
    # === Email validation
    # === Password Complexity
    # === Password re-use
    # Disallows re-using current password when changing the password.  This
    # validation is disabled if the {PasswordArchivable} module is used because
    # it results in redundant validation failures.
    #
    # == Options
    #
    # SecureValidatable adds the following options to the +devise+ declaration:
    #
    # * +password_complexity+: descriptor of the minimum character classes
    #   required for password complexity, i.e.:
    #    { digits: 1, lower: 1, upper: 1, symbol 1}
    # * +email_validation+: the regular expression used to validate e-mails;
    # * +password_length+: a +Range+ expressing password length. Defaults from devise
    #
    module SecureValidatable
      extend ActiveSupport::Concern
      include Devise::Models::Compatibility

      included do |base|
        assert_secure_validations_api!(base)

        devise :database_authenticatable

        already_validated_email = false

        unless has_uniqueness_validation_of_login?
          # validate this every time the record is updated or created.
          validates login_attribute, uniqueness: {
            scope:          authentication_keys[1..-1],
            case_sensitive: !case_insensitive_keys.include?(login_attribute),
          }, unless

          already_validated_email = login_attribute.to_s == 'email'
        end

        unless devise_validation_enabled?
          validates :email, presence: true, if: :email_required?
          unless already_validated_email
            validates :email, uniqueness: true, allow_blank: true, if: :email_changed? # check uniq for email ever
          end

          validates :password, presence: true, confirmation: true, if: :password_required?

          # Validate password length requirements
          validate if: :password_required? do |record|
            validates_with ActiveModel::Validations::LengthValidator, attributes: :password, in: record.class.password_length
          end
        end

        # validate the email address
        validates :email, email: email_validation if email_validation # see https://github.com/devise-security/devise-security/blob/master/README.md#e-mail-validation

        # Check password complexity requirements
        validate if: :password_required? do |record|
          validates_with DeviseSecurity::PasswordComplexityValidator,
                         attributes: :password,
                         constraints: record.class.password_complexity
        end

        # don't allow user to change the password back to the same one
        validate :current_equal_password_validation,
          if: ->(record) { record.devise_modules.include?(:database_authenticatable) },
          unless: ->(record) { record.devise_modules.include?(:password_archivable) }
      end

      protected

      def current_equal_password_validation
        return if new_record? || !will_save_change_to_encrypted_password? || password.blank?

        dummy = self.class.new(encrypted_password: encrypted_password_was).tap do |user|
          user.password_salt = password_salt_was if respond_to?(:password_salt)
        end
        errors.add(:password, :equal_to_current_password) if dummy.valid_password?(password)
      end

      # Checks whether a password is needed or not. For validations only.
      # Passwords are always required if it's a new record, or if the password
      # or confirmation are being set somewhere.
      def password_required?
        !persisted? || !password.nil? || !password_confirmation.nil?
      end

      def email_required?
        true
      end

      class_methods do
        Devise::Models.config(self, :password_complexity, :password_length, :email_validation)

        def assert_secure_validations_api!(base)
          raise "Could not use SecureValidatable on #{base}" unless base.respond_to?(:validates)
        end

        def has_uniqueness_validation_of_login?
          validators.any? do |validator|
            validator.is_a?(ActiveRecord::Validations::UniquenessValidator) &&
              validator.attributes.include?(login_attribute)
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
