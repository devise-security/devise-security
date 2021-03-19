# frozen_string_literal: true

require 'test_helper'

class TestWithSecureValidatable < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  tests MinimumPasswordLengthController

  test 'When using secure_validatable, @minimum_password_length is set' do
    assert_equal 'hi', 'hi'
  end
end
