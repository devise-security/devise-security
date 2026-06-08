# frozen_string_literal: true

require 'test_helper'

class TestExpirable < ActiveSupport::TestCase
  test 'should have required_fields array' do
    assert_equal %i[last_activity_at expired_at], Devise::Models::Expirable.required_fields(User)
  end

  test 'expire! sets expired_at and saves without validation' do
    user = create(:user)

    assert_nil user.expired_at

    user.expire!

    assert_not_nil user.expired_at
    assert_operator user.expired_at, :<=, Time.now.utc
    assert_predicate user, :expired?
  end

  test 'expire! accepts a custom time' do
    user = create(:user)
    future = 1.week.from_now.utc

    user.expire!(future)

    assert_in_delta future, user.expired_at, 1.second
  end

  test 'inactive_message returns :expired when account is expired' do
    user = build(:user, expired_at: 1.day.ago)

    assert_equal :expired, user.inactive_message
  end

  test 'inactive_message delegates to super when not expired' do
    user = build(:user, last_activity_at: Time.now.utc)

    assert_not_equal :expired, user.inactive_message
  end

  test 'mark_expired expires users who are expired by inactivity but have no expired_at' do
    user = create(:user, last_activity_at: 1.year.ago)

    assert_predicate user, :expired?
    assert_nil user.expired_at

    User.mark_expired

    user.reload

    assert_not_nil user.expired_at
  end

  test 'mark_expired does not touch users who already have expired_at set' do
    original_time = 2.days.ago.utc
    user = create(:user, expired_at: original_time, last_activity_at: 1.year.ago)

    User.mark_expired

    user.reload

    assert_in_delta original_time, user.expired_at, 1.second
  end

  test 'mark_expired does not expire active users' do
    user = create(:user, last_activity_at: 1.day.ago)

    User.mark_expired

    user.reload

    assert_nil user.expired_at
  end
end
