# frozen_string_literal: true

require 'test_helper'

# REQUIREMENTS (upstream issue #141):
# - New config: deny_old_passwords_period (ActiveSupport::Duration, default: nil)
# - When set, password reuse is denied based on time window instead of count
# - When period is set, it takes precedence over count-based deny_old_passwords
# - Supports Proc values (instance_exec pattern, consistent with existing configs)
# - nil (default) preserves existing count-based behavior (backward compatible)
class TestPasswordArchivePeriod < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    # Store originals
    @original_deny = Devise.deny_old_passwords
    @original_count = Devise.password_archiving_count
    @original_period = Devise.deny_old_passwords_period

    # Reasonable defaults for these tests
    Devise.deny_old_passwords = true
    Devise.password_archiving_count = 10

    # Clear class-level overrides
    clear_devise_class_vars(User, :deny_old_passwords_period, :deny_old_passwords, :password_archiving_count)
  end

  teardown do
    Devise.deny_old_passwords = @original_deny
    Devise.password_archiving_count = @original_count
    Devise.deny_old_passwords_period = @original_period
    clear_devise_class_vars(User, :deny_old_passwords_period, :deny_old_passwords, :password_archiving_count)
  end

  # ── Default (nil): count-based behavior preserved ──────────────

  test 'period nil (default): count-based denial works as before' do
    Devise.deny_old_passwords_period = nil
    Devise.deny_old_passwords = 2
    Devise.password_archiving_count = 5

    user = create(:user)
    set_password(user, 'Password2')

    # Password1 is within last 2 — denied
    assert_raises(ORMInvalidRecordException) { set_password(user, 'Password1') }

    # Rotate out
    set_password(user, 'Password3')
    set_password(user, 'Password4')

    # Password1 is now outside last 2 — allowed
    assert set_password(user, 'Password1')
  end

  # ── Period set: password within window is denied ───────────────

  test 'period set: password used within time window is denied' do
    Devise.deny_old_passwords_period = 3.months

    user = create(:user)

    travel 1.month do
      set_password(user, 'Password2')

      # Password1 was used 1 month ago, within 3-month window — denied
      assert_raises(ORMInvalidRecordException) { set_password(user, 'Password1') }
    end
  end

  test 'period set: password used outside time window is allowed' do
    Devise.deny_old_passwords_period = 3.months

    user = create(:user)
    set_password(user, 'Password2')

    travel 6.months do
      # Password1 was archived > 3 months ago — allowed
      assert set_password(user, 'Password1')
    end
  end

  test 'period set: no old passwords allows new password' do
    Devise.deny_old_passwords_period = 3.months

    user = create(:user)

    # Only the current password exists (no archives yet), changing to new is fine
    assert set_password(user, 'Password2')
  end

  test 'period set: current password is still denied even without archives' do
    Devise.deny_old_passwords_period = 3.months

    user = create(:user)

    # Reusing current password is always denied (encrypted_password_was check)
    assert_raises(ORMInvalidRecordException) { set_password(user, 'Password1') }
  end

  # ── Period as Proc ─────────────────────────────────────────────

  test 'period as Proc: resolved at call time with instance_exec' do
    User.deny_old_passwords_period = proc { 3.months }

    user = create(:user)
    set_password(user, 'Password2')

    travel 1.month do
      # Within 3-month window — denied
      assert_raises(ORMInvalidRecordException) { set_password(user, 'Password1') }
    end

    travel 6.months do
      # Outside 3-month window — allowed
      assert set_password(user, 'Password1')
    end
  end

  test 'period Proc has access to instance via self' do
    user = build(:user)
    User.deny_old_passwords_period = proc { respond_to?(:email) ? 6.months : nil }

    assert_equal 6.months, user.deny_old_passwords_period
  ensure
    clear_devise_class_vars(User, :deny_old_passwords_period)
  end

  # ── Period takes precedence over count ─────────────────────────

  test 'period takes precedence over deny_old_passwords count when both set' do
    Devise.deny_old_passwords = 2
    Devise.deny_old_passwords_period = 1.month

    user = create(:user)
    set_password(user, 'Password2')
    set_password(user, 'Password3')
    set_password(user, 'Password4')

    # Count-based (2) would allow Password1 (rotated out).
    # But if period is checked: Password1 archive is still recent.
    # Within 1-month window, it should be denied.
    assert_raises(ORMInvalidRecordException) { set_password(user, 'Password1') }

    # After the period expires, it should be allowed
    travel 2.months do
      assert set_password(user, 'Password1')
    end
  end
end
