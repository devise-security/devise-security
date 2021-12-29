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
      include Devise::Models::Compatibility

      def self.included(base)
        base.extend ClassMethods
        assert_secure_validations_api!(base)

        base.class_eval do
          already_validated_email = false

          # validate login in a strict way if not yet validated
          unless uniqueness_validation_of_login?
            validation_condition = "#{login_attribute}_changed?".to_sym

            validates login_attribute, uniqueness: {
                                          scope:          authentication_keys[1..-1],
                                          case_sensitive: !!case_insensitive_keys
                                        },
                                        if: validation_condition

            already_validated_email = login_attribute.to_s == 'email'
          end

          unless devise_validation_enabled?
            validates :email, presence: true, if: :email_required?
            unless already_validated_email
              validates :email, uniqueness: true, allow_blank: true, if: :email_changed? # check uniq for email ever
            end

            validates_presence_of :password, if: :password_required?
            validates_confirmation_of :password, if: :password_required?

            validate if: :password_required? do |record|
              validates_with ActiveModel::Validations::LengthValidator,
                             attributes: :password,
                             allow_blank: true,
                             in: record.password_length
            end
          end

          # extra validations
          # see https://github.com/devise-security/devise-security/blob/master/README.md#e-mail-validation
          validate do |record|
            if email_validation
              validates_with(
                EmailValidator, { attributes: :email }
              )
            end
          end

          validate if: :password_required? do |record|
            validates_with(
              record.password_complexity_validator.is_a?(Class) ? record.password_complexity_validator : record.password_complexity_validator.classify.constantize,
              { attributes: :password }.merge(record.password_complexity)
            )
          end

          # don't allow use same password
          validate :current_equal_password_validation

          # don't allow email to equal password
          validate :email_not_equal_password_validation
        end
      end

      def self.assert_secure_validations_api!(base)
        raise "Could not use SecureValidatable on #{base}" unless base.respond_to?(:validates)
      end

      def current_equal_password_validation
        return if new_record? || !will_save_change_to_encrypted_password? || password.blank?

        dummy = self.class.new(encrypted_password: encrypted_password_was).tap do |user|
          user.password_salt = password_salt_was if respond_to?(:password_salt)
        end
        errors.add(:password, :equal_to_current_password) if dummy.valid_password?(password)
      end

      def email_not_equal_password_validation
        return if allow_passwords_equal_to_email

        return if password.blank? || email.blank? || (!new_record? && !will_save_change_to_encrypted_password?)

        return unless Devise.secure_compare(password.downcase.strip, email.downcase.strip)

        errors.add(:password, :equal_to_email)
      end

      protected

      # Checks whether a password is needed or not. For validations only.
      # Passwords are always required if it's a new record, or if the password
      # or confirmation are being set somewhere.
      #
      # @return [Boolean]
      def password_required?
        !persisted? || !password.nil? || !password_confirmation.nil?
      end

      def email_required?
        true
      end

      delegate(
        :allow_passwords_equal_to_email,
        :email_validation,
        :password_complexity,
        :password_complexity_validator,
        :password_length,
        to: :class
      )

      module ClassMethods
        Devise::Models.config(
          self,
          :allow_passwords_equal_to_email,
          :email_validation,
          :password_complexity,
          :password_complexity_validator,
          :password_length
        )

        private

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
    end
  end
end
