# frozen_string_literal: true

require 'test_helper'

class TestSecureValidatableInformationController < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  tests SecureValidatableInformationController

  def set_minimum_password_length(mapping)
    @request.env["devise.mapping"] = Devise.mappings[mapping]
    @controller.set_secure_validatable_information
    @length = @controller.instance_variable_get(:@minimum_password_length)
    @complexity =
      @controller.instance_variable_get(:@minimum_password_complexity)
  end

  test 'When using secure_validatable, @minimum_password_length is set' do
    set_minimum_password_length(:secure_user)

    assert_equal @length, Devise.password_length.min
  end

  test 'When using secure_validatable, @minimum_password_complexity is set' do
    set_minimum_password_length(:secure_user)

    assert_equal @complexity, Devise.password_complexity
  end

  test 'When not using secure_validatable, @minimum_password_length is not set' do
    set_minimum_password_length(:non_validatable_user)

    assert_nil @length
  end

  test 'When not using secure_validatable, @minimum_password_complexity is not set' do
    set_minimum_password_length(:non_validatable_user)

    assert_nil @complexity
  end
end
