# frozen_string_literal: true

require 'active_support/test_case'

module ActiveSupport
  class TestCase
    mattr_accessor :ip_count
    def generate_ip_address
      self.class.ip_count ||= 0
      self.class.ip_count += 1
      "192.168.1.#{self.class.ip_count}"
    end

    mattr_accessor :email_count
    def generate_unique_username
      self.class.email_count ||= 0
      self.class.email_count += 1
      "test#{self.class.email_count}"
    end

    def generate_unique_email
      "#{generate_unique_username}@example.com"
    end

    def valid_attributes(attributes = {})
      username = generate_unique_username
      {
        username: username,
        email: "#{username}@example.com",
        password: 'Password1'
      }.update(attributes)
    end

    def valid_new_attributes(attributes = {})
      username = generate_unique_username
      valid_attributes({
                         password_confirmation: 'Password1'
                       }).update(attributes)
    end

    def new_user(attributes = {}, klass = User)
      klass.new(valid_attributes(attributes))
    end

    def create_user(attributes = {}, klass = User)
      klass.create!(valid_attributes(attributes))
    end

    def create_traceable_user(attributes = {})
      create_user(attributes, TraceableUser)
    end

    def create_traceable_user_with_limit(attributes = {})
      create_user(attributes, TraceableUserWithLimit)
    end

    # Execute the block setting the given values and restoring old values after
    # the block is executed.
    def swap(object, new_values)
      old_values = {}
      new_values.each do |key, value|
        old_values[key] = object.send key
        object.send :"#{key}=", value
      end
      clear_cached_variables(new_values)
      yield
    ensure
      clear_cached_variables(new_values)
      old_values.each do |key, value|
        object.send :"#{key}=", value
      end
    end

    def clear_cached_variables(options)
      return unless options.key?(:case_insensitive_keys) || options.key?(:strip_whitespace_keys)

      Devise.mappings.each do |_, mapping|
        mapping.to.instance_variable_set(:@devise_parameter_filter, nil)
      end
    end
  end
end
