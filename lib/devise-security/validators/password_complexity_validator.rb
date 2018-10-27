# frozen_string_literal: true

# Password complexity validator
# Options:
# - digit:  minimum number of digits in the validated string
# - lower:  minimum number of lower-case letters in the validated string
# - symbol: minimum number of punctuation characters or symbols in the validated string
# - upper:  minimum number of upper-case letters in the validated string
class DeviseSecurity::PasswordComplexityValidator < ActiveModel::EachValidator
  PATTERNS = {
    digit: /\p{Digit}/,
    digits: /\p{Digit}/,
    lower: /\p{Lower}/,
    upper: /\p{Upper}/,
    symbol: /\p{Punct}|\p{S}/,
    symbols: /\p{Punct}|\p{S}/
  }.freeze

  def validate_each(record, attribute, value)
    active_pattern_keys(record).each do |key|
      minimum = [0, constraints(record).fetch(key).to_i].max
      pattern = Regexp.new PATTERNS[key]

      unless value.to_s.scan(pattern).size >= minimum
        record.errors.add attribute, :"password_complexity.#{key}", count: minimum
      end
    end
  end

  def constraints(record)
    case options[:constraints]
    when Proc
      options[:constraints].call(record)
    else
      options[:constraints]
    end
  end

  def active_pattern_keys(record)
    constraints(record).keys & PATTERNS.keys
  end
end
