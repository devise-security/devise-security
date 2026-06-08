# frozen_string_literal: true

require 'test_helper'

# These tests will interact with the Captcha::SessionsController, which has the necessary patches for Captcha support
# included manually instead of by using Devise.setup
class TestWithCaptcha < ActionDispatch::IntegrationTest
  class MockedCaptchaSessionsController < Captcha::SessionsController
    def check_captcha
      true
    end
  end

  test 'When captcha is enabled, it is inserted correctly' do
    post '/captcha_users/sign_in', params: {
      captcha_user: {
        email: 'wrong@email.com',
        password: 'wrongpassword'
      }
    }

    assert_equal 'The captcha input was invalid.', flash[:alert]
    assert_redirected_to new_captcha_user_session_path
  end

  test 'When captcha is valid, it runs as normal' do
    Captcha::SessionsController.stub :new, MockedCaptchaSessionsController.new do
      post '/captcha_users/sign_in', params: {
        captcha: 'ABCDE',
        user: {
          email: 'wrong@email.com',
          password: 'wrongpassword'
        }
      }
    end

    assert_match(/invalid.*email.*password/i, flash[:alert])
  end
end

# Unit tests for helper methods in DeviseSecurity::Controllers::Helpers
class TestHelperMethods < ActiveSupport::TestCase
  # Minimal class that can include Helpers without triggering before_action
  class FakeController
    def self.before_action(*); end
    include DeviseSecurity::Controllers::Helpers
  end

  setup do
    @helper = FakeController.new
  end

  test 'init_recover_password_captcha includes RecoverPasswordCaptcha module' do
    klass = Class.new(FakeController)
    klass.init_recover_password_captcha

    assert_operator klass, :<, DeviseSecurity::Controllers::Helpers::RecoverPasswordCaptcha
  end

  test 'valid_captcha_or_security_question? returns true when security question matches' do
    resource = Struct.new(:security_question_answer).new('blue')

    assert @helper.valid_captcha_or_security_question?(resource, { security_question_answer: 'blue' })
  end

  test 'valid_captcha_or_security_question? returns false when nothing matches' do
    resource = Struct.new(:security_question_answer).new('blue')

    assert_not @helper.valid_captcha_or_security_question?(resource, { security_question_answer: 'red' })
  end

  test 'valid_captcha_or_security_question? returns false when answer is blank' do
    resource = Struct.new(:security_question_answer).new(nil)

    assert_not @helper.valid_captcha_or_security_question?(resource, { security_question_answer: nil })
  end
end

# These tests interact with the Devise::SessionsController, which does not have the necessary patches for Captcha
# included
class TestWithoutCaptcha < ActionDispatch::IntegrationTest
  test 'When captcha is not enabled, it is not inserted' do
    post '/users/sign_in', params: {
      user: {
        email: 'wrong@email.com',
        password: 'wrongpassword'
      }
    }

    assert_match(/invalid.*email.*password/i, flash[:alert])
  end
end
