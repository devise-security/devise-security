# frozen_string_literal: true

require 'test_helper'

class TestPasswordArchivable < ActiveSupport::TestCase
  setup do
    Devise.password_archiving_count = 2
  end

  teardown do
    Devise.password_archiving_count = 1
  end

  test 'required_fields should be an empty array' do
    assert_empty Devise::Models::PasswordArchivable.required_fields(User)
  end

  test 'cannot use same password' do
    user = create(:user)
    assert_raises(ORMInvalidRecordException) { set_password(user, 'Password1') }
  end

  test 'indirectly saving associated user does not cause deprecation warning' do
    if Rails.gem_version >= Gem::Version.new('7.1')
      old_behavior = Rails.application.deprecators[:active_record].behavior
      Rails.application.deprecators.behavior = :raise
    else
      old_behavior = ActiveSupport::Deprecation.behavior
      ActiveSupport::Deprecation.behavior = :raise
    end

    user = build(:user)
    widget = Widget.new(user: user)
    assert_nothing_raised { widget.save }
  ensure
    if Rails.gem_version >= Gem::Version.new('7.1')
      Rails.application.deprecators.behavior = old_behavior
    else
      ActiveSupport::Deprecation.behavior = old_behavior
    end
  end

  test 'does not save an OldPassword if user password was originally nil' do
    user = build(:user, password: nil)
    set_password(user, 'Password1')

    assert_equal 0, OldPassword.count
  end

  test 'cannot reuse archived passwords' do
    assert_equal 2, Devise.password_archiving_count

    user = create(:user)

    assert_equal 0, OldPassword.count
    set_password(user, 'Password2')

    assert_equal 1, OldPassword.count

    assert_raises(ORMInvalidRecordException) { set_password(user, 'Password1') }
    set_password(user, 'Password3')

    assert_equal 2, OldPassword.count

    # rotate first password out of archive
    assert set_password(user, 'Password4')

    # archive count was 2, so first password should work again
    assert set_password(user, 'Password1')
    assert set_password(user, 'Password2')
  end

  test 'the option should be dynamic during runtime' do
    class ::User
      def archive_count
        1
      end
    end

    user = create(:user)

    assert set_password(user, 'Password2')

    assert_raises(ORMInvalidRecordException) { set_password(user, 'Password2') }

    assert_raises(ORMInvalidRecordException) { set_password(user, 'Password1') }
  ensure
    User.send(:remove_method, :archive_count)
  end

  test 'max_old_passwords returns numeric value when deny_old_passwords is an integer' do
    user = build(:user)
    user.define_singleton_method(:deny_old_passwords) { 5 }

    assert_equal 5, user.max_old_passwords
  end

  test 'max_old_passwords returns 0 when deny_old_passwords is false' do
    user = build(:user)
    user.define_singleton_method(:deny_old_passwords) { false }

    assert_equal 0, user.max_old_passwords
  end

  test 'archive_passwords clears all old passwords when deny_old_passwords is false' do
    Devise.deny_old_passwords = true
    user = create(:user)
    set_password(user, 'Password2')

    assert_operator OldPassword.count, :>, 0

    Devise.deny_old_passwords = false
    set_password(user, 'Password3')

    assert_equal 0, user.old_passwords.count
  ensure
    Devise.deny_old_passwords = true
  end

  test 'default sort orders do not affect archiving' do
    class ::OldPassword
      default_scope { order(created_at: :asc) }
    end

    assert_equal 2, Devise.password_archiving_count

    user = create(:user)

    assert_equal 0, OldPassword.count
    set_password(user, 'Password2')

    assert_equal 1, OldPassword.count

    assert_raises(ORMInvalidRecordException) { set_password(user, 'Password1') }
    set_password(user, 'Password3')

    assert_equal 2, OldPassword.count

    # rotate first password out of archive
    assert set_password(user, 'Password4')

    # archive count was 2, so first password should work again
    assert set_password(user, 'Password1')
    assert set_password(user, 'Password2')
  end
end
