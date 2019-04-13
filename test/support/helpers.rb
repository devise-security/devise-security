# frozen_string_literal: true

# Copyright 2009-2019 Plataformatec. http://plataformatec.com.br
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
#                                  distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


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

    def valid_attributes(attributes = {})
      username = generate_unique_username
      {
          username: username,
          email: "#{username}@microsoft.com",
          password: 'Password1',
          password_confirmation: 'Password1',
      }.update(attributes)
    end

    def new_user(attributes = {})
      User.new(valid_attributes(attributes))
    end

    def create_user(attributes = {})
      User.create!(valid_attributes(attributes))
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
      if options.key?(:case_insensitive_keys) || options.key?(:strip_whitespace_keys)
        Devise.mappings.each do |_, mapping|
          mapping.to.instance_variable_set(:@devise_parameter_filter, nil)
        end
      end
    end
  end
end
