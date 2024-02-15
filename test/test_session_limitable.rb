# frozen_string_literal: true

require 'test_helper'

class TestSessionLimitable < ActiveSupport::TestCase
  class ModifiedUser < User
    def skip_session_limitable?
      true
    end
  end

  test 'should have required_fields array' do
    assert_equal %i[unique_session_id max_active_sessions reject_sessions timeout_in], Devise::Models::SessionLimitable.required_fields(User)
  end

  test 'check is not skipped by default' do
    user = User.new(email: generate_unique_email, password: 'password1', password_confirmation: 'password1')
    assert_not(user.skip_session_limitable?)
  end

  test 'default check can be overridden by record instance' do
    modified_user = ModifiedUser.new(email: generate_unique_email, password: 'password1', password_confirmation: 'password1')
    assert(modified_user.skip_session_limitable?)
  end

  class SessionLimitableUser < User
    devise :session_limitable
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid
  end

  test 'includes Devise::Models::Compatibility' do
    assert_kind_of(Devise::Models::Compatibility, SessionLimitableUser.new)
  end

  test '#update_unique_session_id!(value) updates valid record' do
    user = User.create! password: 'passWord1', password_confirmation: 'passWord1', email: generate_unique_email
    assert user.persisted?
    assert_nil user.unique_session_id
    user.update_unique_session_id!('unique_value')
    user.reload

    assert_equal('unique_value', user.unique_session_id)
  end

  test '#update_unique_session_id!(value) updates invalid record atomically' do
    email = generate_unique_email
    user = User.create! password: 'passWord1', password_confirmation: 'passWord1', email: email
    assert user.persisted?
    user.email = ''

    assert_predicate user, :invalid?
    assert_nil user.unique_session_id
    user.update_unique_session_id!('unique_value')
    user.reload
    assert_equal(email, user.email)
    assert_equal('unique_value', user.unique_session_id)
  end

  test '#update_unique_session_id!(value) raises an exception on an unpersisted record' do
    user = User.create

    assert_not user.persisted?
    assert_raises(Devise::Models::Compatibility::NotPersistedError) { user.update_unique_session_id!('unique_value') }
  end

  test '#allow_limitable_authentication? returns true' do
    user = new_user

    assert_predicate user, :allow_limitable_authentication?
  end

  test '#deactivate_expired_sessions! returns true' do
    user = new_user

    assert user.deactivate_expired_sessions!
  end

  test '#max_active_sessions returns 1' do
    swap Devise, max_active_sessions: 10 do
      user = new_user

      assert_equal 1, user.max_active_sessions
    end
  end

  test '#reject_sessions? returns false' do
    swap Devise, reject_sessions: true do
      user = new_user

      assert_not user.reject_sessions?
    end
  end
end

class TestSessionLimitableWithTraceable < ActiveSupport::TestCase
  def default_options
    @default_options ||= { ip_address: generate_ip_address, user_agent: 'UA' }
  end

  test 'allow authentication when within max' do
    swap Devise, max_active_sessions: 2 do
      user = create_traceable_user_with_limit
      user.log_traceable_session!(default_options)

      assert_predicate user, :allow_limitable_authentication?
    end
  end

  test 'calls #deactivate_expired_sessions! when reject sessions' do
    swap Devise, max_active_sessions: 1, reject_sessions: true do
      user = create_traceable_user_with_limit
      user.log_traceable_session!(default_options)

      user.expects(:deactivate_expired_sessions!).returns(true).at_least_once

      assert_predicate user, :allow_limitable_authentication?
    end
  end

  test 'remove old sessions when not reject sessions' do
    swap Devise, max_active_sessions: 1, reject_sessions: false do
      user = create_traceable_user_with_limit
      user.log_traceable_session!(default_options)

      assert_predicate user, :allow_limitable_authentication?

      sessions = user.reload.session_histories.select { |h| h.active }

      assert_equal(0, sessions.size)
    end
  end

  test 'deactivate expired sessions' do
    time_now = Time.current
    timeout_in = 5.seconds
    swap Devise, timeout_in: timeout_in, max_active_sessions: 10 do
      user = create_traceable_user_with_limit

      Timecop.freeze(time_now) do
        user.log_traceable_session!(default_options)
      end

      Timecop.freeze(timeout_in) do
        user.log_traceable_session!(default_options)
      end

      Timecop.freeze(time_now + 6.seconds) do
        user.log_traceable_session!(default_options)
        user.deactivate_expired_sessions!
      end

      sessions = user.reload.session_histories.select { |h| h.active }

      assert_equal(2, sessions.size)
    end
  end

  test '#max_active_sessions returns field' do
    swap Devise, max_active_sessions: 10 do
      user = new_user({}, TraceableUserWithLimit)

      assert_equal 10, user.max_active_sessions
    end
  end

  test '#reject_sessions? returns field' do
    swap Devise, reject_sessions: true do
      user = new_user({}, TraceableUserWithLimit)

      assert_predicate user, :reject_sessions?
    end
  end
end
