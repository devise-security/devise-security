# frozen_string_literal: true

require 'test_helper'

# Tests for upstream issue #494: Throttle update_last_activity! to reduce DB writes.
#
# REQUIREMENT: When last_activity_update_interval is configured to a positive
# duration, update_last_activity! should skip the DB write if last_activity_at
# was updated less than that interval ago. This prevents hundreds of unnecessary
# writes per session for apps with many authenticated requests.
#
# Default behavior (nil) must remain unchanged: every call writes to DB.
class TestLastActivityThrottle < ActiveSupport::TestCase
  setup do
    @original_interval = Devise.last_activity_update_interval
    @user = create(:user)
  end

  teardown do
    Devise.last_activity_update_interval = @original_interval
    @user.destroy if @user.persisted?
  end

  # ── Default (nil) — backward compatible, always writes ─────────

  test 'default last_activity_update_interval is nil' do
    assert_nil Devise.last_activity_update_interval
  end

  test 'when interval is nil, always writes to DB' do
    Devise.last_activity_update_interval = nil
    @user.update_attribute_without_validatons_or_callbacks(:last_activity_at, 1.second.ago)

    old_value = @user.last_activity_at
    @user.update_last_activity!
    @user.reload

    assert_operator @user.last_activity_at, :>, old_value
  end

  test 'when interval is 0, always writes to DB' do
    Devise.last_activity_update_interval = 0
    @user.update_attribute_without_validatons_or_callbacks(:last_activity_at, 1.second.ago)

    old_value = @user.last_activity_at
    @user.update_last_activity!
    @user.reload

    assert_operator @user.last_activity_at, :>, old_value
  end

  # ── First request (nil timestamp) — always writes ──────────────

  test 'when last_activity_at is nil, always writes regardless of throttle' do
    Devise.last_activity_update_interval = 5.minutes

    assert_nil @user.last_activity_at

    @user.update_last_activity!
    @user.reload

    assert_not_nil @user.last_activity_at
  end

  # ── Throttle enabled, timestamp recent — skips write ───────────

  test 'when interval set and timestamp is recent, skips DB write' do
    Devise.last_activity_update_interval = 5.minutes
    recent_time = 2.minutes.ago
    @user.update_attribute_without_validatons_or_callbacks(:last_activity_at, recent_time)

    @user.update_last_activity!
    @user.reload

    # Should NOT have been updated — still the same value
    assert_in_delta recent_time.to_f, @user.last_activity_at.to_f, 1.0
  end

  # ── Throttle enabled, timestamp old — writes ───────────────────

  test 'when interval set and timestamp is old, writes to DB' do
    Devise.last_activity_update_interval = 5.minutes
    old_time = 10.minutes.ago
    @user.update_attribute_without_validatons_or_callbacks(:last_activity_at, old_time)

    @user.update_last_activity!
    @user.reload

    assert_operator @user.last_activity_at, :>, old_time
  end

  # ── Instance method delegates to class config ──────────────────

  test 'last_activity_update_interval instance method delegates to class config' do
    Devise.last_activity_update_interval = 3.minutes

    assert_equal User.last_activity_update_interval, @user.last_activity_update_interval
  end

  # ── Per-record override ────────────────────────────────────────

  test 'per-record override of last_activity_update_interval is respected' do
    Devise.last_activity_update_interval = 5.minutes
    recent_time = 2.minutes.ago
    @user.update_attribute_without_validatons_or_callbacks(:last_activity_at, recent_time)

    # Default interval (5 min) would skip, but override to 1 min means 2 min ago is stale
    @user.define_singleton_method(:last_activity_update_interval) { 1.minute }

    @user.update_last_activity!
    @user.reload

    assert_operator @user.last_activity_at, :>, recent_time
  end

  # ── Duration support ───────────────────────────────────────────

  test 'accepts ActiveSupport::Duration values' do
    Devise.last_activity_update_interval = 30.seconds

    assert_equal 30.seconds, Devise.last_activity_update_interval
  end

  test 'accepts integer values (seconds)' do
    Devise.last_activity_update_interval = 300

    assert_equal 300, Devise.last_activity_update_interval
  end
end
