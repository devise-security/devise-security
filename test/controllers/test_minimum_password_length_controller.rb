# frozen_string_literal: true

require 'test_helper'

class TestWithSecureValidatable < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  tests MinimumPasswordLengthController

  test 'When using secure_validatable, @minimum_password_length is set' do
    @request.env["devise.mapping"] = Devise.mappings[:secure_user]
    assert_equal @controller.set_minimum_password_length, Devise.password_length.min
  end

  test 'When using validatable, @minimum_password_length is set' do
    @request.env["devise.mapping"] = Devise.mappings[:validatable_user]
    assert_equal @controller.set_minimum_password_length, Devise.password_length.min
  end
end
