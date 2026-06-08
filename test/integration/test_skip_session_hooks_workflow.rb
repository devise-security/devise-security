# frozen_string_literal: true

require 'test_helper'

# Tests for env-based skip mechanism matching Devise's canonical pattern.
#
# REQUIREMENT: Controllers and ActionCable connections must be able to skip
# session_limitable and session_traceable checks by setting request env vars:
#   env['devise.skip_session_limitable'] = true
#   env['devise.skip_session_traceable'] = true
#
# This follows the same pattern as Devise core's:
#   env['devise.skip_timeoutable']
#   env['devise.skip_trackable']
#
# See upstream issues #421 and #375.

class TestSkipSessionLimitableViaEnv < ActionDispatch::IntegrationTest
  setup do
    @user = create_user
    @user.confirm
  end

  test 'env skip on login does not assign unique_session_id' do
    open_session do |session|
      # Simulate a controller setting env before Warden auth
      session.post(
        new_user_session_path,
        params: { user: { email: @user.email, password: 'Password1' } },
        env: { 'devise.skip_session_limitable' => true }
      )
      session.assert_redirected_to '/'

      # unique_session_id should NOT be set when skip is active
      assert_nil @user.reload.unique_session_id
    end
  end

  test 'env skip on fetch does not trigger session mismatch logout' do
    first_session = open_session
    second_session = open_session

    # Login from first session
    first_session.tap do |session|
      sign_in(@user, session)
      session.assert_redirected_to '/'
    end

    # Login from second session (kicks first session normally)
    second_session.tap do |session|
      sign_in(@user, session)
      session.assert_redirected_to '/'
    end

    # First session fetches with skip — should NOT be logged out
    first_session.tap do |session|
      session.get widgets_path, env: { 'devise.skip_session_limitable' => true }
      # With skip, the mismatch check is bypassed
      session.assert_response(:success)
    end
  end
end

class TestSkipSessionTraceableViaEnv < ActionDispatch::IntegrationTest
  setup do
    @user = create_traceable_user
    @user.confirm
  end

  test 'env skip on login does not create session history' do
    open_session do |session|
      session.post(
        new_traceable_user_session_path,
        params: { traceable_user: { email: @user.email, password: 'Password1' } },
        env: { 'devise.skip_session_traceable' => true }
      )
      # Should authenticate but not create session history
      session.assert_redirected_to '/'

      assert_equal 0, @user.session_histories.count
    end
  end

  test 'env skip on fetch does not validate or update token' do
    open_session do |session|
      scope = sign_in(@user, session)
      session.assert_redirected_to '/'

      # Invalidate the token to prove skip works
      token = session.controller.warden.session(scope)['unique_traceable_token']
      @user.expire_session_token!(token)

      # Fetch with skip — should NOT be logged out despite invalid token
      session.get widgets_path, env: { 'devise.skip_session_traceable' => true }
      session.assert_response(:success)
    end
  end
end
