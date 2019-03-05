# frozen_string_literal: true

require 'test_helper'

class TestSessionTraceable < ActiveSupport::TestCase
  def default_options
    @default_options ||= { ip_address: generate_ip_address, user_agent: 'UA' }
  end

  test 'required_fields should contain the fields that Devise uses' do
    assert_same_elements Devise::Models::SessionTraceable.required_fields(User),
                         [:session_history_class, :session_ip_verification]
  end

  test 'custom session_traceable should not raise exception' do
    swap Devise, session_history_class: 'CustomSessionHistory' do
      assert_nothing_raised do
        create_user.log_traceable_session!(default_options)
      end
    end
  end

  test 'inherited session_traceable should not raise exception' do
    swap Devise, session_history_class: 'InheritedSessionHistory' do
      assert_nothing_raised do
        create_user.log_traceable_session!(default_options)
      end
    end
  end

  test 'should not raise exception' do
    assert_nothing_raised do
      create_user.log_traceable_session!(default_options)
    end
  end

  test 'should rescue record invalid exception' do
    assert_nothing_raised do
      create_user.log_traceable_session!(default_options)
    end
  end

  test 'token should not be blank' do
    assert_not_empty create_user.log_traceable_session!(default_options)
  end

  test 'token should be paranoid with ip address' do
    user = create_user
    token = user.log_traceable_session!(default_options)

    assert_not user.accept_traceable_token?(token)
    assert user.accept_traceable_token?(token, ip_address: default_options[:ip_address])
  end

  test 'token should be accepted' do
    user = create_user
    token = user.log_traceable_session!(default_options)
    assert user.accept_traceable_token?(token, default_options)
  end

  test 'token should be accepted even different ip if not session_ip_verification' do
    swap Devise, session_ip_verification: false do
      user = create_user
      token = user.log_traceable_session!(default_options)
      assert user.accept_traceable_token?(token, ip_address: '0.0.0.0')
      assert user.accept_traceable_token?(token)
    end
  end

  test 'expired token should not be accepted' do
    user = create_user
    token = user.log_traceable_session!(default_options)
    user.expire_session_token(token)

    assert_not user.accept_traceable_token?(token)
  end

  test 'last_accessed_at should be updated' do
    user = create_user
    token = user.log_traceable_session!(default_options)
    assert user.update_traceable_token(token)
  end

  test 'last_accessed_at should not equal to previous' do
    user = create_user
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
