# frozen_string_literal: true

require 'test_helper'

# REQUIREMENTS (upstream issue #453):
# - password_archiving_count and deny_old_passwords must accept Proc values.
# - Procs are resolved at call time (not stored time).
# - Procs have access to the model instance via self (instance_exec).
# - Existing non-Proc configs (Integer, Boolean) must continue to work.
class TestPasswordArchivableProcConfigs < ActiveSupport::TestCase
  setup do
    # Clear any stale class ivars left by other test files (e.g., test_password_archivable.rb)
    clear_devise_class_vars(User, :deny_old_passwords, :password_archiving_count)
  end

  # ── deny_old_passwords as Proc ───────────────────────────────

  test 'deny_old_passwords Proc is resolved at call time' do
    user = build(:user)
    call_count = 0
    User.deny_old_passwords = proc {
      call_count += 1
      3
    }

    result = user.deny_old_passwords

    assert_equal 3, result
    assert_equal 1, call_count
  ensure
    clear_devise_class_vars(User, :deny_old_passwords)
  end

  test 'deny_old_passwords Proc has access to instance via self' do
    user = build(:user)
    User.deny_old_passwords = proc { respond_to?(:email) ? 5 : 0 }

    assert_equal 5, user.deny_old_passwords
  ensure
    clear_devise_class_vars(User, :deny_old_passwords)
  end

  test 'deny_old_passwords Proc returning true denies all old passwords' do
    user = build(:user)
    User.deny_old_passwords = proc { true }

    assert user.deny_old_passwords
    assert_predicate user.max_old_passwords, :positive?
  ensure
    clear_devise_class_vars(User, :deny_old_passwords)
  end

  # ── password_archiving_count as Proc ─────────────────────────

  test 'archive_count Proc is resolved at call time' do
    user = build(:user)
    User.password_archiving_count = proc { 7 }

    assert_equal 7, user.archive_count
  ensure
    clear_devise_class_vars(User, :password_archiving_count)
  end

  test 'archive_count Proc has access to instance via self' do
    user = build(:user)
    User.password_archiving_count = proc { respond_to?(:email) ? 4 : 1 }

    assert_equal 4, user.archive_count
  ensure
    clear_devise_class_vars(User, :password_archiving_count)
  end

  # ── Integration: Procs flow through max_old_passwords ────────

  test 'max_old_passwords uses resolved Proc value from deny_old_passwords' do
    user = build(:user)
    User.deny_old_passwords = proc { 4 }

    assert_equal 4, user.max_old_passwords
  ensure
    clear_devise_class_vars(User, :deny_old_passwords)
  end

  # ── Regression: non-Proc configs still work ──────────────────

  test 'deny_old_passwords integer config still works' do
    user = build(:user)
    User.deny_old_passwords = 3

    assert_equal 3, user.deny_old_passwords
  ensure
    clear_devise_class_vars(User, :deny_old_passwords)
  end

  test 'deny_old_passwords boolean true config still works' do
    user = build(:user)
    User.deny_old_passwords = true

    assert user.deny_old_passwords
  ensure
    clear_devise_class_vars(User, :deny_old_passwords)
  end
end
