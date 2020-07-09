# frozen_string_literal: true

# Password complexity validator
# Options:
# - digit:  minimum number of digits in the validated string
# - digits: minimum number of digits in the validated string
# - lower:  minimum number of lower-case letters in the validated string
# - symbol: minimum number of punctuation characters or symbols in the validated string
# - symbols: minimum number of punctuation characters or symbols in the validated string
# - upper:  minimum number of upper-case letters in the validated string
class DeviseSecurity::PasswordComplexityValidator < ActiveModel::EachValidator
  PATTERNS = {
    digit: /\p{Digit}/,
    digits: /\p{Digit}/,
    lower: /\p{Lower}/,
    symbol: /\p{Punct}|\p{S}/,
    symbols: /\p{Punct}|\p{S}/,
    upper: /\p{Upper}/
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
    # TODO - there are examples where there is and isn't a `constraints`. Is one format deprecated?
    constraints = options[:constraints] || options

    case constraints
    when Proc
      constraints.call(record)
    else
      constraints
    end
  end

  def active_pattern_keys(record)
    constraints(record).keys & PATTERNS.keys
  end
end
