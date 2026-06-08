# frozen_string_literal: true

require 'test_helper'

class TestSessionTraceable < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  def default_options
    @default_options ||= { ip_address: generate_ip_address, user_agent: 'UA' }
  end

  test 'should have required_fields array' do
    assert_equal %i[session_history_class session_ip_verification], Devise::Models::SessionTraceable.required_fields(TraceableUser)
  end

  test 'custom session_history_class should work' do
    swap Devise, session_history_class: 'CustomSessionHistory' do
      assert_nothing_raised do
        create_traceable_user.log_traceable_session!(default_options)
      end
    end
  end

  test 'inherited session_history_class should work' do
    swap Devise, session_history_class: 'InheritedSessionHistory' do
      assert_nothing_raised do
        create_traceable_user.log_traceable_session!(default_options)
      end
    end
  end

  test 'should not raise exception on log' do
    assert_nothing_raised do
      assert_not_nil create_traceable_user.log_traceable_session!(default_options)
    end
  end

  test 'should return nil on ActiveRecord error' do
    user = create_traceable_user
    token = user.log_traceable_session!(default_options)
    # Create with duplicate token to trigger uniqueness constraint
    result = user.log_traceable_session!(default_options.merge(token: token))

    assert_nil result
  end

  test 'token should not be blank' do
    assert_not_empty create_traceable_user.log_traceable_session!(default_options)
  end

  test 'token should be verified against ip address by default' do
    user = create_traceable_user
    token = user.log_traceable_session!(default_options)

    assert_not user.accept_traceable_token?(token)
    assert user.accept_traceable_token?(token, ip_address: default_options[:ip_address])
  end

  test 'token should be accepted with matching options' do
    user = create_traceable_user
    token = user.log_traceable_session!(default_options)

    assert user.accept_traceable_token?(token, default_options)
  end

  test 'token accepted from any ip when session_ip_verification disabled' do
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
    user.expire_session_token!(token)

    assert_not user.accept_traceable_token?(token)
  end

  test 'update_traceable_token! updates last_accessed_at' do
    user = create_traceable_user
    token = user.log_traceable_session!(default_options)

    assert user.update_traceable_token!(token)
  end

  test 'update_traceable_token! returns nil for unknown token' do
    user = create_traceable_user

    assert_nil user.update_traceable_token!('nonexistent-token')
  end

  test 'last_accessed_at advances on update' do
    user = create_traceable_user
    token = user.log_traceable_session!(default_options)
    session = user.find_traceable_by_token(token)
    old_last_accessed = session.last_accessed_at

    travel 2.seconds do
      user.update_traceable_token!(token)
      session.reload

      assert_operator session.last_accessed_at, :>, old_last_accessed
    end
  end
end

class TestSessionTraceableWithLimit < ActiveSupport::TestCase
  def default_options
    @default_options ||= { ip_address: generate_ip_address, user_agent: 'UA' }
  end

  test 'token logged when authentication allowed' do
    user = create_traceable_user_with_limit

    user.stub(:allow_limitable_authentication?, true) do
      assert_not_empty user.log_traceable_session!(default_options)
    end
  end

  test 'token not logged when authentication denied' do
    user = create_traceable_user_with_limit

    user.stub(:allow_limitable_authentication?, false) do
      assert_not user.log_traceable_session!(default_options)
    end
  end
end
