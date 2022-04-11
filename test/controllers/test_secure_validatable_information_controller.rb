# frozen_string_literal: true

require 'test_helper'

class TestSecureValidatableInformationController < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  tests SecureValidatableInformationController

  def setup_for(mapping)
    @request.env["devise.mapping"] = Devise.mappings[mapping]

    get :index

    @length = @controller.instance_variable_get(:@minimum_password_length)
    @complexity =
      @controller.instance_variable_get(:@minimum_password_complexity)
  end

  test 'When using secure_validatable, @minimum_password_length is set' do
    setup_for(:user)

    assert_equal @length, Devise.password_length.min
  end

  test 'When using secure_validatable, '\
       '@minimum_password_complexity is set' do
    setup_for(:user)

    assert_equal @complexity, Devise.password_complexity
 end

  test 'When using validatable, @minimum_password_length is set' do
    setup_for(:validatable_user)

    assert_equal @length, Devise.password_length.min
  end

  test 'When using validatable, @minimum_password_complexity is not set' do
    setup_for(:validatable_user)

    assert_nil @complexity
  end

  test 'When using neither, @minimum_password_length is not set' do
    setup_for(:non_devise_user)

    assert_nil @length
  end

  test 'When using neither, @minimum_password_complexity is not set' do
    setup_for(:non_devise_user)

    assert_nil @complexity
  end
end
