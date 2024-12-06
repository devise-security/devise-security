# frozen_string_literal: true

require 'test_helper'

class TestSessionLimitableWorkflow < ActionDispatch::IntegrationTest
  include IntegrationHelpers

  setup do
    @user = User.create!(password: 'passWord1',
                         password_confirmation: 'passWord1',
                         email: generate_unique_email)
    @user.confirm
  end

  test 'failed login' do
    assert_nil @user.unique_session_id

    open_session do |session|
      failed_sign_in(@user, session)
      session.assert_response(:success)
      assert_equal session.flash[:alert], I18n.t('devise.failure.invalid', authentication_keys: 'Email')
      assert_nil @user.reload.unique_session_id
    end
  end

  test 'successful login' do
    assert_nil @user.unique_session_id

    open_session do |session|
      sign_in(@user, session)
      session.assert_redirected_to '/'
      session.get widgets_path
      session.assert_response(:success)
      assert_equal('success', session.response.body)
      assert_not_nil @user.reload.unique_session_id
    end
  end

  test 'session is logged out when another session is created' do
    first_session = open_session
    second_session = open_session
    unique_session_id = nil

    first_session.tap do |session|
      sign_in(@user, session)
      session.assert_redirected_to '/'
      session.get widgets_path
      session.assert_response(:success)
      assert_equal('success', session.response.body)
      unique_session_id = @user.reload.unique_session_id
      assert_not_nil unique_session_id
    end

    second_session.tap do |session|
      sign_in(@user, session)
      session.assert_redirected_to '/'
      session.get widgets_path
      session.assert_response(:success)
      assert_equal('success', session.response.body)
      assert_not_equal unique_session_id, @user.reload.unique_session_id
    end

    first_session.tap do |session|
      session.get widgets_path
      session.assert_redirected_to new_user_session_path
      assert_equal session.flash[:alert], I18n.t('devise.failure.session_limited')
    end
  end

  test 'session is cleared when user logs out' do
    assert_nil @user.unique_session_id

    open_session do |session|
      sign_in(@user, session)
      session.assert_redirected_to '/'
      session.get widgets_path
      session.assert_response(:success)
      assert_equal('success', session.response.body)
      assert_not_nil @user.reload.unique_session_id

      sign_out(session)
      session.assert_redirected_to '/'
      assert_nil @user.reload.unique_session_id
    end
  end
end
