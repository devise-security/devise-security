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

  # @param record [ActiveModel::Model]
  # @param attribute [Symbol]
  # @param password [String]
  def validate_each(record, attribute, password)
    return if password.blank?

    active_patterns.each do |pattern_name, minimum|
      next if password.scan(patterns[pattern_name]).size >= minimum

      record.errors.add(
        attribute,
        :"password_complexity.#{pattern_name}",
        count: minimum
      )
    end
  end

  # A Hash of the valid patterns that have been enabled. These are normalized to
  # have singular key names and positive limits. Negative or zero limits are
  # ignored.
  #
  # @return [Hash<Symbol,Integer>]
  def active_patterns
    options.transform_keys { |pattern| pattern.to_s.singularize.to_sym } # singularize keys
           .slice(*patterns.keys) # ignore any unknown patterns and other options
           .transform_values { |value| [0, value.to_i].max } # normalize to positive limits
           .reject { |_, value| value.zero? } # ignore zero limits
  end
end
