# frozen_string_literal: true

# This validator class is used to determine if a password complies with the
# specified complexity requirements. For example:
#
#     validates_with DeviseSecurity::PasswordComplexityValidator,
#       attributes: :password,
#       digits: 1, # minimum number of digits in the validated string (also :digit)
#       lower: 1, # minimum number of lower-case letters in the validated string
#       symbols: 1, # minimum number of punctuation characters or symbols in the validated string (also :symbol)
#       upper: 1, # minimum number of upper-case letters in the validated string
#
# The values for the constraints used by this validator when used as part of
# {SecureValidateable} is determined in the following order:
#
# 1. An instance method named `password_complexity`
# 2. A class method named `password_complexity`
# 3. The global configuration
#
# Methods used to override the configuration should return a Hash with keys
# corresponding to the ones in {PATTERNS} and Integer values
class DeviseSecurity::PasswordComplexityValidator < ActiveModel::EachValidator
  PATTERNS = {
    digit: /\p{Digit}/,
    digits: /\p{Digit}/,
    lower: /\p{Lower}/,
    symbol: /\p{Punct}|\p{S}/,
    symbols: /\p{Punct}|\p{S}/,
    upper: /\p{Upper}/,
  }.freeze

  # When validating a record against a set of attributes, this method is called
  # for each attribute to determine if it is valid.
  #
  # @param record [ActiveModel::Validations] the record to validate against
  # @param attribute [Symbol] attribute to validate
  # @param value [String] the value of the attribute to check for validity
  def validate_each(record, attribute, value)
    options.each_key do |key|
      raise "Unknown password constraint (#{key})" unless PATTERNS.key?(key)

      minimum = [0, options.fetch(key).to_i].max

      record.errors.add attribute, :"password_complexity.#{key}", count: minimum if value.to_s.scan(PATTERNS[key]).size < minimum
    end
  end
end
