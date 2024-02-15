# frozen_string_literal: true

require 'test_helper'

class TestSessionTraceableWorkflow < ActionDispatch::IntegrationTest
  setup do
    @user = create_traceable_user
    @user.confirm
  end

  test 'failed login' do
    open_session do |session|
      failed_sign_in(@user, session)

      session.assert_response(:success)
      assert_equal session.flash[:alert], I18n.t('devise.failure.invalid', authentication_keys: 'Email')
      assert_predicate @user.session_histories, :empty?
    end
  end

  test 'successful login' do
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

  test 'last_accessed_at are updated on each request' do
    open_session do |session|
      scope = sign_in(@user, session)
      token = session.controller.warden.session(scope)['unique_traceable_token']
      trace = @user.find_traceable_by_token(token)
      first_accessed_at = trace.last_accessed_at

      new_accessed_at = first_accessed_at + 1.second
      Timecop.freeze(new_accessed_at) do
        session.get root_path
        trace.reload

        assert_equal trace.last_accessed_at.to_s, new_accessed_at.to_s
        assert_not_equal trace.last_accessed_at.to_s, first_accessed_at.to_s
      end
    end
  end

  test 'session record should expire on sign out' do
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

  test 'logout when failed to log' do
    open_session do |session|
      TraceableUser.any_instance.stubs(:log_traceable_session!).returns(nil)

      scope = sign_in(@user, session)
      assert_not session.controller.send(:warden).authenticated?(scope)
    end
  end

  test 'logout when token is invalid' do
    open_session do |session|
      scope = sign_in(@user, session)

      TraceableUser.any_instance.stubs(:accept_traceable_token?).returns(false)
      session.get widgets_path

      assert_not session.controller.send(:warden).authenticated?(scope)
    end
  end
end

class TestSessionTraceableWithLimitWorkflow < ActionDispatch::IntegrationTest
  setup do
    @user = create_traceable_user_with_limit
    @user.confirm
  end

  test 'logout when failed to log' do
    open_session do |session|
      TraceableUserWithLimit.any_instance.stubs(:log_traceable_session!).returns(nil)

      scope = sign_in(@user, session)
      assert_not session.controller.send(:warden).authenticated?(scope)
    end
  end

  test 'unique_session_id backwardcompatibity' do
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
