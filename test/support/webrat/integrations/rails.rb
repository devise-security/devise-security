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

require 'webrat/core/elements/form'
require 'action_dispatch/testing/integration'

module Webrat
  Form.class_eval do
    def self.parse_rails_request_params(params)
      Rack::Utils.parse_nested_query(params)
    end
  end

  module Logging
    # Avoid RAILS_DEFAULT_LOGGER deprecation warning
    def logger # :nodoc:
      ::Rails.logger
    end
  end

  class RailsAdapter
    protected

    def do_request(http_method, url, data, headers)
      update_protocol(url)
      integration_session.send(http_method, normalize_url(url), params: data, headers: headers)
    end
  end
end

module ActionDispatch #:nodoc:
  IntegrationTest.class_eval do
    include Webrat::Methods
    include Webrat::Matchers
  end
end
