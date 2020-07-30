# frozen_string_literal: true

require_relative 'compatibility'
require_relative '../validators/password_complexity_validator'

module Devise
  module Models
    # SecureValidatable creates better validations with more validation for security
    #
    # == Options
    #
    # SecureValidatable adds the following options to devise_for:
    #
    #   * +email_regexp+: the regular expression used to validate e-mails;
    #   * +password_length+: a range expressing password length. Defaults from devise
    #   * +password_regex+: need strong password. Defaults to /(?=.*\d)(?=.*[a-z])(?=.*[A-Z])/
    #
    module SecureValidatable
      extend ActiveSupport::Concern
      include Devise::Models::Compatibility

      included do
        assert_secure_validations_api!(self)

        add_uniqueness_validations
        add_presence_validations

        # extra validations
        validates :email, email: email_validation if email_validation # see https://github.com/devise-security/devise-security/blob/master/README.md#e-mail-validation
        validates(
          :password,
          'devise_security/password_complexity': password_complexity,
          if: :password_required?,
        )

        # don't allow use same password
        validate :current_equal_password_validation
      end

      class_methods do
        def assert_secure_validations_api!(base)
          raise "Could not use SecureValidatable on #{base}" unless base.respond_to?(:validates)
        end

        Devise::Models.config(self, :password_complexity, :password_length, :email_validation)

        private

        def add_uniqueness_validations
          # validate login in a strict way if not yet validated
          add_validation_for_login_item unless uniqueness_validation_of_login?

          # @todo This used to be `to_s`; is that to allow string or symbol?
          validated_email = login_attribute == :email

          # add uniqueness validation to email unless it would have been added
          # by Devise or we would have added it via
          # `add_validation_for_login_item` above
          add_uniqueness_validation_for_email unless devise_validation_enabled? || validated_email
        end

        def add_presence_validations
          return if devise_validation_enabled?

          validates :email, presence: true, if: :email_required?
          validates :password, presence: true, length: password_length, confirmation: true, if: :password_required?
        end

        def add_validation_for_login_item
          validation_condition = "#{login_attribute}_changed?".to_sym

          validates(
            login_attribute,
            uniqueness: {
              scope: authentication_keys[1..-1],
              case_sensitive: !!case_insensitive_keys,
            },
            if: validation_condition,
          )
        end

        def add_uniqueness_validation_for_email
          # check uniq for email ever
          validates :email, uniqueness: true, allow_blank: true, if: :email_changed?
        end

        def uniqueness_validation_of_login?
          validators.any? do |validator|
            validator_orm_klass = DEVISE_ORM == :active_record ? ActiveRecord::Validations::UniquenessValidator : ::Mongoid::Validatable::UniquenessValidator
            validator.is_a?(validator_orm_klass) && validator.attributes.include?(login_attribute)
          end
        end

        def login_attribute
          authentication_keys[0]
        end

        def devise_validation_enabled?
          ancestors.map(&:to_s).include? 'Devise::Models::Validatable'
        end
      end

      # See if the new proposed password is the same as the current password.
      def current_equal_password_validation
        return if cannot_equal_existing_password?

        dummy = self.class.new(encrypted_password: encrypted_password_was).tap do |user|
          user.password_salt = password_salt_was if respond_to?(:password_salt)
        end

        errors.add(:password, :equal_to_current_password) if dummy.valid_password?(password)
      end

      protected

      # Checks whether a password is needed or not. For validations only.
      # Passwords are always required if it's a new record, or if the password
      # or confirmation are being set somewhere.
      def password_required?
        !persisted? || !password.nil? || !password_confirmation.nil?
      end

      # When checking if a new password matches the current, there are some
      # cases where we know this can't be true (before we even compare the old
      # and new). These are used during validation and provide quicker checks
      # than having to encrypt and compare passwords.
      # @return [Boolean]
      def cannot_equal_existing_password?
        new_record? || !will_save_change_to_encrypted_password? || password.blank?
      end

      def email_required?
        true
      end
    end
  end
end
