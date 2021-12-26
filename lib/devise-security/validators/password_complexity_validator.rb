# frozen_string_literal: true

# Password Complexity Validator
#
# Options:
# - `digit | digits`:  minimum number of digits in the validated string. Uses
#   the `digit` localization key.
# - `lower`:  minimum number of lower-case letters in the validated string
# - `symbol | symbols`: minimum number of punctuation characters or symbols in
#   the validated string. Uses the `symbol` localization key.
# - `upper`:  minimum number of upper-case letters in the validated string
class DeviseSecurity::PasswordComplexityValidator < ActiveModel::EachValidator
  # A Hash of the possible valid patterns that can be checked against. The keys
  # for this Hash are singular symbols corresponding to entries in the
  # localization files. Override or redefine this method if you want to include
  # custom patterns (e.g., `letter: /\p{Alpha}/` for all letters).
  #
  # @return [Hash<Symbol,Regexp>]
  def patterns
    {
      digit: /\p{Digit}/,
      lower: /\p{Lower}/,
      symbol: /\p{Punct}|\p{S}/,
      upper: /\p{Upper}/
    }
  end

  # Validate the complexity of the password. This validation does not check to
  # ensure the password is not blank. That is the responsibility of other
  # validations. This validator will also ignore any patterns that are not
  # explicitly configured to be used or whose minimum limits are less than 1.
  #
  # @param record [ActiveModel::Model]
  # @param attribute [Symbol]
  # @param password [String]
  def validate_each(record, attribute, password)
    return if password.blank?

    options.sort.each do |pattern_name, minimum|
      normalized_option = pattern_name.to_s.singularize.to_sym

      next unless patterns.key?(normalized_option)
      next unless minimum.positive?
      next if password.scan(patterns[normalized_option]).size >= minimum

      record.errors.add(
        attribute,
        :"password_complexity.#{normalized_option}",
        count: minimum
      )
    end
  end
end
