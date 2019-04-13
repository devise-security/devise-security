# frozen_string_literal: true

require 'test_helper'

class TestSessionHistory < ActionDispatch::IntegrationTest
  def unique_traceable_token
    @controller.user_session['unique_traceable_token']
  end

  test 'check if unique_traceable_token is set' do
    sign_in_as_user
    assert_not_nil unique_traceable_token
  end

  test 'last_accessed_at are updated on each request' do
    user = current_user
    sign_in_as_user

    session = user.find_traceable_by_token(unique_traceable_token)
    first_accessed_at = session.last_accessed_at

    new_time = 2.seconds.from_now
    Timecop.freeze(new_time) do
      visit root_path

      session.reload
      assert session.last_accessed_at > first_accessed_at
    end
  end

  test 'session record should expire on sign out' do
    user = current_user
    sign_in_as_user

    session = user.find_traceable_by_token(unique_traceable_token)
    assert session.active?

    visit destroy_user_session_path
    session.reload
    assert_not session.active?
  end

  test 'sign in when failed to log session should fail' do
    SessionHistory.stubs(:create!).raises(ActiveRecord::ActiveRecordError)
    sign_in_as_user

    assert_not warden.authenticated?(:user)
  end

  test 'logout when token is invalid' do
    sign_in_as_user
    assert warden.authenticated?(:user)

    User.any_instance.stubs(:accept_traceable_token?).returns(false)
    visit root_path

    assert_not warden.authenticated?(:user)
  end
end
