# frozen_string_literal: true

require 'active_support/test_case'
require 'devise/version'

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

    def devise_invalid_login_message
      key = Gem::Version.new(Devise::VERSION) >= Gem::Version.new('5') ? 'email' : 'Email'
      I18n.t('devise.failure.invalid', authentication_keys: key)
    end
  end
end
