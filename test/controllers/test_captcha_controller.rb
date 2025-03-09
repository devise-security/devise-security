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

    assert_equal 'Invalid Email or password.', flash[:alert]
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

    assert_equal 'Invalid Email or password.', flash[:alert]
  end
end
