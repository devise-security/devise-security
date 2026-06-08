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

    def generate_unique_username
      generate(:username)
    end

    def generate_unique_email
      generate(:email)
    end

    def valid_attributes(attributes = {})
      username = generate_unique_username
      {
        username: username,
        email: "#{username}@example.com",
        password: 'Password1'
      }.update(attributes)
    end

    def new_user(attributes = {}, klass = User)
      factory_name = klass.name.underscore.to_sym
      build(factory_name, **valid_attributes(attributes))
    end

    def create_user(attributes = {}, klass = User)
      factory_name = klass.name.underscore.to_sym
      create(factory_name, **valid_attributes(attributes))
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
      yield
    ensure
      old_values.each do |key, value|
        object.send :"#{key}=", value
      end
    end
  end
end
