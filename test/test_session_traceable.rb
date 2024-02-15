# frozen_string_literal: true

require 'test_helper'

class TestSessionTraceable < ActiveSupport::TestCase
  def default_options
    @default_options ||= { ip_address: generate_ip_address, user_agent: 'UA' }
  end

  test 'should have required_fields array' do
    assert_equal %i[session_history_class session_ip_verification], Devise::Models::SessionTraceable.required_fields(TraceableUser)
  end

  test 'custom session_traceable should not raise exception' do
    swap Devise, session_history_class: 'CustomSessionHistory' do
      assert_nothing_raised do
        create_traceable_user.log_traceable_session!(default_options)
      end
    end
  end

  test 'inherited session_traceable should not raise exception' do
    swap Devise, session_history_class: 'InheritedSessionHistory' do
      assert_nothing_raised do
        create_traceable_user.log_traceable_session!(default_options)
      end
    end
  end

  test 'unsupported session_traceable should not raise exception' do
    swap Devise, session_history_class: 'UnsupportedSessionHistory' do
      assert_raise do
        create_traceable_user.send(:session_traceable_adapter)
      end
    end
  end

  test 'should not raise exception' do
    assert_nothing_raised do
      refute_nil create_traceable_user.log_traceable_session!(default_options)
    end
  end

  test 'should rescue record invalid exception' do
    create_traceable_user.send(:session_traceable_adapter).stub(:create!, ->(_opts) { raise ActiveRecord::ActiveRecordError }) do
      assert_nothing_raised do
        assert_nil create_traceable_user.log_traceable_session!(default_options)
      end
    end
  end

  test 'token should not be blank' do
    assert_not_empty create_traceable_user.log_traceable_session!(default_options)
  end

  test 'token should be paranoid with ip address' do
    user = create_traceable_user
    token = user.log_traceable_session!(default_options)

    assert_not user.accept_traceable_token?(token)
    assert user.accept_traceable_token?(token, ip_address: default_options[:ip_address])
  end

  test 'token should be accepted' do
    user = create_traceable_user
    token = user.log_traceable_session!(default_options)

    assert user.accept_traceable_token?(token, default_options)
  end

  test 'token should be accepted even different ip if not session_ip_verification' do
    swap Devise, session_ip_verification: false do
      user = create_traceable_user
      token = user.log_traceable_session!(default_options)

      assert user.accept_traceable_token?(token, ip_address: '0.0.0.0')
      assert user.accept_traceable_token?(token)
    end
  end

  test 'expired token should not be accepted' do
    user = create_traceable_user
    token = user.log_traceable_session!(default_options)
    user.expire_session_token(token)

    assert_not user.accept_traceable_token?(token)
  end

  test 'last_accessed_at should be updated' do
    user = create_traceable_user
    token = user.log_traceable_session!(default_options)

    assert user.update_traceable_token(token)
  end

  test 'last_accessed_at should not equal to previous' do
    user = create_traceable_user
    token = user.log_traceable_session!(default_options)
    session = user.find_traceable_by_token(token)

    old_last_accessed = session.last_accessed_at

    new_time = 2.seconds.from_now
    Timecop.freeze(new_time) do
      user.update_traceable_token(token)

      session.reload

      assert session.last_accessed_at > old_last_accessed
    end
  end
end

class TestSessionTraceableWithLimit < ActiveSupport::TestCase
  def default_options
    @default_options ||= { ip_address: generate_ip_address, user_agent: 'UA' }
  end

  test 'token should log when allowed' do
    user = create_traceable_user_with_limit

    user.stub(:allow_limitable_authentication?, true) do
      assert_not_empty user.log_traceable_session!(default_options)
    end
  end

  test 'token should not log when not allowed' do
    user = create_traceable_user_with_limit

    user.stub(:allow_limitable_authentication?, false) do
      assert_not user.log_traceable_session!(default_options)
    end
  end
end
