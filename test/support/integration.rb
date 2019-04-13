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

require 'devise/test/integration_helpers'

module ActionDispatch
  class IntegrationTest
    include Devise::Test::IntegrationHelpers

    # %w( get post patch put head delete xml_http_request
    #           xhr get_via_redirect post_via_redirect
    #         ).each do |method|
    %w[get post put].each do |method|
      if Rails.version >= '5.0.0'
        define_method(method) do |url, options = {}|
          if options.empty?
            super url
          else
            super url, options
          end
        end
      else
        define_method(method) do |url, options = {}|
          if options[:xhr] == true
            xml_http_request  __method__, url, options[:params] || {}, options[:headers]
          else
            super url, options[:params] || {}, options[:headers]
          end
        end
      end
    end

    setup do
      header('HTTP_USER_AGENT', 'UA')
    end

    def warden
      request.env['warden']
    end

    def current_user(opts = {})
      @current_user ||= begin
        attrs = opts.slice(:username, :email, :password, :password_confirmation)
        attrs[:created_at] = Time.now.utc
        user = create_user(attrs)
        user.confirm unless opts[:confirm] == false
        user.lock_access! if opts[:locked] == true
        user
      end
    end

    def sign_in_as_user(options = {})
      user = current_user(options)
      visit_with_option options[:visit], new_user_session_path
      fill_in 'email', with: options[:email] || user.email
      fill_in 'password', with: options[:password] || 'Password1'
      check 'remember me' if options[:remember_me] == true
      yield if block_given?
      click_button 'Log In'
      user
    end

    protected

    def visit_with_option(given, default)
      case given
      when String
        visit given
      when FalseClass
        # Do nothing
      else
        visit default
      end
    end
  end
end
