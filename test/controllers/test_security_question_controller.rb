# frozen_string_literal: true

require 'test_helper'

class TestWithSecurityQuestion < ActionDispatch::IntegrationTest
  setup do
    @user = SecurityQuestionUser.create!(
      username: 'hello',
      email: generate_unique_email,
      password: 'A1234567z!',
      security_question_answer: 'Right Answer'
    )
    @user.lock_access!
  end

  test 'When security question is enabled, it is inserted correctly' do
    post(
      '/security_question_users/unlock',
      params: {
        security_question_answer: 'wrong answer',
        security_question_user: {
          email: @user.email
        }
      }
    )

    assert_equal I18n.t('devise.invalid_security_question'), flash[:alert]
    assert_redirected_to new_security_question_user_unlock_path
  end

  test 'When security_question is valid, it runs as normal' do
    post(
      '/security_question_users/unlock',
      params: {
        security_question_answer: @user.security_question_answer,
        security_question_user: {
          email: @user.email
        }
      }
    )

    assert_equal I18n.t('devise.unlocks.send_instructions'), flash[:notice]
    assert_redirected_to new_security_question_user_session_path
  end
end

class TestWithoutSecurityQuestion < ActionDispatch::IntegrationTest
  setup do
    @user = User.create(
      username: 'hello',
      email: generate_unique_email,
      password: '1234',
      security_question_answer: 'Right Answer'
    )
    @user.lock_access!
  end

  test 'When security question is not enabled it is not inserted' do
    post '/users/unlock', params: { user: { email: @user.email } }

    assert_equal I18n.t('devise.unlocks.send_instructions'), flash[:notice]
    assert_redirected_to new_user_session_path
  end
end
