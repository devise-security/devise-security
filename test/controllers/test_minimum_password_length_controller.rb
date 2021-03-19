# frozen_string_literal: true

require 'test_helper'

class TestWithSecureValidatable < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  tests MinimumPasswordLengthController

  test 'When using secure_validatable, @minimum_password_length is set' do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    # byebug
    # puts @controller.set_minimum_password_length
    assert_equal @controller.set_minimum_password_length, Devise.password_length.min
  end
end
