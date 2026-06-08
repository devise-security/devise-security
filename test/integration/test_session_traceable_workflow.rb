# frozen_string_literal: true

require 'test_helper'

class TestSessionTraceableWorkflow < ActionDispatch::IntegrationTest
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @user = create_traceable_user
    @user.confirm
  end

  test 'failed login does not create session history' do
    open_session do |session|
      failed_sign_in(@user, session)

      session.assert_response(:success)

      assert_match(/invalid.*email.*password/i, session.flash[:alert])
      assert_predicate @user.session_histories, :empty?
    end
  end

  test 'successful login creates session history' do
    assert_equal(0, @user.session_histories.count)

    open_session do |session|
      scope = sign_in(@user, session)

      session.assert_redirected_to '/'
      session.get widgets_path

      session.assert_response(:success)

      assert_equal('success', session.response.body)
      assert_predicate @user.session_histories, :any?
      assert_equal session.controller.warden.session(scope)['unique_traceable_token'], @user.session_histories.last.token
    end
  end

  test 'last_accessed_at updated on each request' do
    open_session do |session|
      scope = sign_in(@user, session)
      token = session.controller.warden.session(scope)['unique_traceable_token']
      trace = @user.find_traceable_by_token(token)
      first_accessed_at = trace.last_accessed_at

      travel 1.second do
        session.get root_path
        trace.reload

        assert_operator trace.last_accessed_at, :>, first_accessed_at
      end
    end
  end

  test 'session record expires on sign out' do
    open_session do |session|
      scope = sign_in(@user, session)
      token = session.controller.warden.session(scope)['unique_traceable_token']
      trace = @user.find_traceable_by_token(token)

      assert_predicate trace, :active?

      sign_out(@user, session)
      trace.reload

      assert_not trace.active?
    end
  end

  test 'logout when log_traceable_session! returns nil' do
    open_session do |session|
      TraceableUser.define_method(:log_traceable_session!) { |_opts| nil }

      scope = sign_in(@user, session)

      assert_not session.controller.send(:warden).authenticated?(scope)
    ensure
      TraceableUser.remove_method(:log_traceable_session!)
    end
  end

  test 'logout when token becomes invalid' do
    open_session do |session|
      scope = sign_in(@user, session)

      TraceableUser.define_method(:accept_traceable_token?) { |_token, _opts| false }
      session.get widgets_path

      assert_not session.controller.send(:warden).authenticated?(scope)
    ensure
      TraceableUser.remove_method(:accept_traceable_token?)
    end
  end

  test 'before_logout does not crash when record is nil (expired session)' do
    open_session do |session|
      scope = sign_in(@user, session)

      warden = session.controller.send(:warden)
      token = warden.session(scope)['unique_traceable_token']

      assert_predicate token, :present?, 'token should exist after sign in'

      # Simulate expired session: user can't be deserialized but session
      # data (including the traceable token) is still present in the cookie.
      # Warden's proxy#logout passes nil for @users.delete(scope) in this case.
      warden.instance_variable_get(:@users).delete(scope)

      assert_nothing_raised do
        warden.logout(scope)
      end
    end
  end
end

class TestSessionTraceableWithLimitWorkflow < ActionDispatch::IntegrationTest
  setup do
    @user = create_traceable_user_with_limit
    @user.confirm
  end

  test 'logout when log_traceable_session! returns nil' do
    open_session do |session|
      TraceableUserWithLimit.define_method(:log_traceable_session!) { |_opts| nil }

      scope = sign_in(@user, session)

      assert_not session.controller.send(:warden).authenticated?(scope)
    ensure
      TraceableUserWithLimit.remove_method(:log_traceable_session!)
    end
  end

  test 'unique_session_id backward compatibility migration' do
    open_session do |session|
      scope = sign_in(@user, session, :traceable_user_with_limit)
      # Simulate the old unique_session_id by removing the unique_traceable_token
      unique_session_id = Devise.friendly_token
      @user.update_unique_session_id!(unique_session_id)
      Warden::Manager.prepend_after_set_user(only: :fetch) do |_record, warden, _options|
        if warden.authenticated?(scope)
          warden.session(scope).delete('unique_traceable_token')
          warden.session(scope)['unique_session_id'] = unique_session_id
        end
      end

      assert_difference -> { @user.session_histories.count } do
        session.get widgets_path
      end

      assert_not_empty session.request.env['warden'].session(scope)['unique_traceable_token']
      assert_nil session.request.env['warden'].session(scope)['unique_session_id']
    end
  end
end
