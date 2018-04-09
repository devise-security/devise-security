module DeviseSecurity
  # String complexity validator
  # Validates complexity of e.g. passwords
  # Options:
  # - digit:  minimum number of digits in the validated string
  # - lower:  minimum number of lower-case letters in the validated string
  # - symbol: minimum number of punctuation characters or symbols in the validated string
  # - upper:  minimum number of upper-case letters in the validated string
  class ComplexityValidator < ActiveModel::EachValidator
    PATTERNS = {
      digit: /\p{Digit}/,
      lower: /\p{Lower}/,
      upper: /\p{Upper}/,
      symbol: /\p{Punct}|\p{S}/,
    }.freeze

    def validate_each(record, attribute, value)
      (options.keys & PATTERNS.keys).each do |key|
        minimum = [0, options[key].to_i].max
        pattern = Regexp.new PATTERNS[key]

        unless (value || '').scan(pattern).size >= minimum
          record.errors.add attribute, :"complexity.#{key}", count: minimum
        end
      end
    end
  end
end
