module DeviseSecurity
  # Passowrd complexity validator
  # Options:
  # - digit:  minimum number of digits in the validated string
  # - lower:  minimum number of lower-case letters in the validated string
  # - symbol: minimum number of punctuation characters or symbols in the validated string
  # - upper:  minimum number of upper-case letters in the validated string
  class PasswordComplexityValidator < ActiveModel::EachValidator
    PATTERNS = {
      digit: /\p{Digit}/,
      digits: /\p{Digit}/,
      lower: /\p{Lower}/,
      upper: /\p{Upper}/,
      symbol: /\p{Punct}|\p{S}/,
      symbols: /\p{Punct}|\p{S}/,
    }.freeze

    def validate_each(record, attribute, value)
      (options.keys & PATTERNS.keys).each do |key|
        minimum = [0, options[key].to_i].max
        pattern = Regexp.new PATTERNS[key]

        unless (value || '').scan(pattern).size >= minimum
          record.errors.add attribute, :"password_complexity.#{key}", count: minimum
        end
      end
    end
  end
end
