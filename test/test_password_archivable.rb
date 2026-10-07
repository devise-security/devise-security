# frozen_string_literal: true

require 'test_helper'

class TestPasswordArchivable < ActiveSupport::TestCase
  setup do
    Devise.password_archiving_count = 2
  end

  teardown do
    Devise.password_archiving_count = 1
  end

  def set_password(user, password)
    user.password = password
    user.password_confirmation = password
    user.save!
  end

  test 'required_fields should be an empty array' do
    assert_empty Devise::Models::PasswordArchivable.required_fields(User)
  end

  test 'cannot use same password' do
    user = User.create email: generate_unique_email, password: 'Password1', password_confirmation: 'Password1'
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

    user = User.new email: generate_unique_email, password: 'Password1', password_confirmation: 'Password1'
    widget = Widget.new(user: user)
    assert_nothing_raised { widget.save }

    if Rails.gem_version >= Gem::Version.new('7.1')
      Rails.application.deprecators.behavior = old_behavior
    else
      ActiveSupport::Deprecation.behavior = old_behavior
    end
  end

  test 'does not save an OldPassword if user password was originally nil' do
    user = User.new(email: generate_unique_email, password: nil, password_confirmation: nil)
    set_password(user, 'Password1')
    assert_equal 0, OldPassword.count
  end

  test 'cannot reuse archived passwords' do
    assert_equal 2, Devise.password_archiving_count

    user = User.create! email: generate_unique_email, password: 'Password1', password_confirmation: 'Password1'
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

    user = User.create email: generate_unique_email, password: 'Password1', password_confirmation: 'Password1'

    assert set_password(user, 'Password2')

    assert_raises(ORMInvalidRecordException) { set_password(user, 'Password2') }

    assert_raises(ORMInvalidRecordException) { set_password(user, 'Password1') }
  end

  def configure_archive(user, deny:, count:)
    user.define_singleton_method(:deny_old_passwords) { deny }
    user.define_singleton_method(:archive_count) { count }
  end

  def create_user_with_password_history(deny:, count:, changes:)
    user = User.create! email: generate_unique_email, password: 'Password1', password_confirmation: 'Password1'
    configure_archive(user, deny: deny, count: count)
    (2..(changes + 1)).each { |index| set_password(user, "Password#{index}") }
    user
  end

  test 'keeps password_archiving_count passwords but checks only deny_old_passwords of them' do
    user = create_user_with_password_history(deny: 1, count: 3, changes: 4)

    # Password1 was rotated out, Password2..Password4 are archived, Password5 is the current one
    assert_equal 3, user.old_passwords.count

    assert_raises(ORMInvalidRecordException) { set_password(user, 'Password5') }
    assert_raises(ORMInvalidRecordException) { set_password(user, 'Password4') }

    # still archived, but older than the deny_old_passwords most recent ones
    assert set_password(user, 'Password3')
  end

  test 'keeps at least deny_old_passwords passwords when password_archiving_count is lower' do
    user = create_user_with_password_history(deny: 3, count: 1, changes: 4)

    assert_equal 3, user.old_passwords.count

    assert_raises(ORMInvalidRecordException) { set_password(user, 'Password2') }
    assert set_password(user, 'Password1')
  end

  test 'does not archive passwords when deny_old_passwords is false' do
    user = create_user_with_password_history(deny: false, count: 3, changes: 2)

    assert_equal 0, user.old_passwords.count
    assert set_password(user, 'Password1')
  end

  test 'default sort orders do not affect archiving' do
    class ::OldPassword
      default_scope { order(created_at: :asc) }
    end

    assert_equal 2, Devise.password_archiving_count

    user = User.create! email: generate_unique_email, password: 'Password1', password_confirmation: 'Password1'
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
