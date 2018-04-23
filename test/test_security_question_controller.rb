# frozen_string_literal: true

require 'test_helper'

class TestWithSecurityQuestion < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  tests SecurityQuestion::UnlocksController

  setup do
    @user = User.create(username: 'hello', email: 'hello@path.travel',
                        password: '1234', security_question_answer: 'Right Answer')
    @user.lock_access!

    @request.env['devise.mapping'] = Devise.mappings[:security_question_user]
  end

  test 'When security question is enabled, it is inserted correctly' do
    if Rails.version < "5"
      post :create, {
        security_question_user: {
          email: @user.email
        }, security_question_answer: "wrong answer"
      }
    else
      post :create, params: {
        security_question_user: {
          email: @user.email
        }, security_question_answer: "wrong answer"
      }
    end

    assert_equal 'The security question answer was invalid.', flash[:alert]
    assert_redirected_to new_security_question_user_unlock_path
  end

  test 'When security_question is valid, it runs as normal' do
    if Rails.version < "5"
      post :create, {
        security_question_user: {
          email: @user.email
        }, security_question_answer: @user.security_question_answer
      }
    else
      post :create, params: {
        security_question_user: {
          email: @user.email
        }, security_question_answer: @user.security_question_answer
      }
    end

    assert_equal 'You will receive an email with instructions for how to unlock your account in a few minutes.', flash[:notice]
    assert_redirected_to new_security_question_user_session_path
  end
end

class TestWithoutSecurityQuestion < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  tests Devise::UnlocksController

  setup do
    @user = User.create(username: 'hello', email: 'hello@path.travel',
                        password: '1234', security_question_answer: 'Right Answer')
    @user.lock_access!

    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  test 'When security question is not enabled it is not inserted' do
    if Rails.version < "5"
      post :create, {
        user: {
          email: @user.email
        }
      }
    else
      post :create, params: {
        user: {
          email: @user.email
        }
      }
    end

    assert_equal 'You will receive an email with instructions for how to unlock your account in a few minutes.', flash[:notice]
    assert_redirected_to new_user_session_path
  end
end
