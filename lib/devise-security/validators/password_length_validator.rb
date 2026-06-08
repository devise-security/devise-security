# frozen_string_literal: true

module DeviseSecurity
  # Thin wrapper around +ActiveModel::Validations::LengthValidator+ that reads
  # the allowed length range from the record at validation time rather than
  # capturing it at class-definition time.
  #
  # This makes the validator discoverable via +User.validators_on(:password)+
  # while still supporting per-record dynamic config overrides (e.g., a Proc
  # or an overridden instance method for +password_length+).
  #
  # @example Registration in SecureValidatable
  #   validates_with DeviseSecurity::PasswordLengthValidator,
  #                  attributes: :password,
  #                  if: :password_required?
  class PasswordLengthValidator < ActiveModel::EachValidator
    # Validate password length using the record's +password_length+ range.
    #
    # @param record [ActiveModel::Model] the model instance being validated
    # @param attribute [Symbol] the attribute name (+:password+)
    # @param value [String, nil] the password value
    def validate_each(record, attribute, value)
      return if value.blank?

      length_range = record.password_length

      ActiveModel::Validations::LengthValidator.new(
        attributes: [attribute],
        in: length_range,
        allow_blank: true
      ).validate_each(record, attribute, value)
    end
  end
end
