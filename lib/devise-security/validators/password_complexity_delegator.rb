# frozen_string_literal: true

module DeviseSecurity
  # Thin wrapper that delegates to the record's configured
  # +password_complexity_validator+ class at validation time. This makes the
  # complexity validator discoverable via +User.validators_on(:password)+
  # while still supporting per-record dynamic config overrides.
  #
  # At validation time this reads:
  # - +record.password_complexity_validator+ — the validator class (or name)
  # - +record.password_complexity+ — the options hash (e.g., +{ upper: 1 }+)
  #
  # @example Registration in SecureValidatable
  #   validates_with DeviseSecurity::PasswordComplexityDelegator,
  #                  attributes: :password,
  #                  if: :password_required?
  class PasswordComplexityDelegator < ActiveModel::EachValidator
    # Validate password complexity by delegating to the record's configured
    # complexity validator class with the record's complexity options.
    #
    # @param record [ActiveModel::Model] the model instance being validated
    # @param attribute [Symbol] the attribute name (+:password+)
    # @param value [String, nil] the password value
    def validate_each(record, attribute, value)
      return if value.blank?

      klass = record.password_complexity_validator
      klass = klass.classify.constantize unless klass.is_a?(Class)

      complexity_opts = record.password_complexity || {}

      klass.new(
        attributes: [attribute],
        **complexity_opts
      ).validate_each(record, attribute, value)
    end
  end
end
