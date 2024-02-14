# frozen_string_literal: true

require 'active_support/test_case'

module ActiveSupport
  class TestCase
    mattr_accessor :email_count
    def generate_unique_username
      self.class.email_count ||= 0
      self.class.email_count += 1
      "test#{self.class.email_count}"
    end

    def generate_unique_email
      "#{generate_unique_username}@example.com"
    end
  end
end
