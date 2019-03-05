# frozen_string_literal: true

require 'test_helper'

class TestSessionLimitable < ActiveSupport::TestCase
  test 'required_fields should contain the fields that Devise uses' do
    assert_same_elements Devise::Models::SessionLimitable.required_fields(User),
                         [:session_history_class, :max_active_sessions, :timeout_in, :limit_sessions]
  end

  test 'allow to authenticate' do
    user = create_user
    assert user.allow_limitable_authentication?
  end

  test 'should deactivate old session when exceeded' do
    user = create_user
    token = user.log_traceable_session!
    assert user.allow_limitable_authentication?
    assert_not user.find_traceable_by_token(token).active?
  end

  test 'should reject authentication when exceeded' do
    swap Devise, limit_sessions: true do
      user = create_user
      user.log_traceable_session!
      assert_not user.allow_limitable_authentication?
    end
  end

  test 'should deactivate timeout session when reject on limit' do
    time = (User.timeout_in + 1.second).from_now

    swap Devise, limit_sessions: true do
      user = create_user
      token = user.log_traceable_session!

      Timecop.freeze(time) do
        assert user.allow_limitable_authentication?
        assert_not user.find_traceable_by_token(token).active?
      end
    end
  end
end
