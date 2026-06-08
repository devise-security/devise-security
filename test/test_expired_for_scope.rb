# frozen_string_literal: true

require 'test_helper'

# REQUIREMENTS (upstream issue #449):
# - expired_for scope must include BOTH manually expired users (expired_at set)
#   AND inactivity-expired users (expired_at nil, last_activity_at older than
#   expire_after + delete_expired_after).
# - Fresh users (nil last_activity_at, nil expired_at) must be excluded.
# - Users whose delete window hasn't elapsed must be excluded.
class TestExpiredForScope < ActiveSupport::TestCase
  # ORM-agnostic column update (bypasses validations/callbacks)
  def update_fields(record, attrs)
    if DEVISE_ORM == :active_record
      record.update_columns(attrs)
    else
      record.set(attrs)
    end
  end

  test 'expired_for includes user with expired_at older than delete_expired_after' do
    user = create(:user)
    update_fields(user, expired_at: (User.delete_expired_after + 1.day).ago)

    assert_includes User.expired_for, user
  end

  test 'expired_for excludes user with expired_at within delete_expired_after window' do
    user = create(:user)
    update_fields(user, expired_at: 1.day.ago)

    assert_not_includes User.expired_for, user
  end

  test 'expired_for includes inactivity-expired user with nil expired_at' do
    user = create(:user)
    update_fields(user,
                  last_activity_at: (User.expire_after + User.delete_expired_after + 1.day).ago,
                  expired_at: nil)

    assert_includes User.expired_for, user
  end

  test 'expired_for excludes inactivity-expired user whose delete window has not elapsed' do
    user = create(:user)
    update_fields(user,
                  last_activity_at: (User.expire_after + 1.day).ago,
                  expired_at: nil)

    assert_not_includes User.expired_for, user
  end

  test 'expired_for excludes fresh user with no activity and no expired_at' do
    user = create(:user)
    update_fields(user, last_activity_at: nil, expired_at: nil)

    assert_not_includes User.expired_for, user
  end

  test 'delete_all_expired removes inactivity-expired users past delete window' do
    user = create(:user)
    update_fields(user,
                  last_activity_at: (User.expire_after + User.delete_expired_after + 1.day).ago,
                  expired_at: nil)

    assert_difference 'User.count', -1 do
      User.delete_all_expired
    end
  end
end
