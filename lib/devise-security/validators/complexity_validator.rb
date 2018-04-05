module DeviseSecurity
  # String complexity validator
  # Validates complexity of e.g. passwords
  # Options:
  # - digit: minimum number of digits in the validated string
  # - lower: minimum number of lower-case letters in the validated string
  # - punct: minimum number of punctuation characters or symbols in the validated string
  # - upper: minimum number of upper-case letters in the validated string
  class ComplexityValidator < ActiveModel::EachValidator
    POSIX_CLASSES = %i[digit lower punct upper].freeze

    def validate_each(record, attribute, value)
      (options.keys & POSIX_CLASSES).each do |char_class|
        minimum = [0, options[char_class].to_i].max
        pattern = Regexp.new "[[:#{char_class}:]]"

        unless (value || '').scan(pattern).size >= minimum
          record.errors.add attribute, :"complexity.#{char_class}", count: minimum
        end
      end
    end
  end
end
