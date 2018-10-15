# frozen_string_literal: true

require 'test_helper'

class TestPasswordArchivable < ActiveSupport::TestCase
  setup do
    Devise.expire_password_after = 2.months
  end

  teardown do
    Devise.expire_password_after = 90.days
  end

  test 'does nothing if disabled' do
    Devise.expire_password_after = false
    user = User.create email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1'
    refute user.need_change_password?
    refute user.password_expired?
    user.need_change_password!
    refute user.need_change_password?
    refute user.password_expired?
  end

  test 'password change can be requested' do
    Devise.expire_password_after = true
    user = User.create email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1'
    refute user.need_change_password?
    refute user.password_expired?
    refute user.password_change_requested?
    user.need_change_password!
    assert user.need_change_password?
    refute user.password_expired? # it's not too old because it's not set at all
    assert user.password_change_requested?
  end

  test 'password expires' do
    user = User.create email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1'
    refute user.need_change_password?
    refute user.password_expired?
    refute user.password_too_old?
    user.update(password_changed_at: Time.now.ago(3.months))
    assert user.password_too_old?
    assert user.need_change_password?
    assert user.password_expired?
    refute user.password_change_requested?
  end

  test 'saving a record records the time the password was changed' do
    user = User.new email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1'
    assert user.password_changed_at.nil?
    refute user.password_change_requested?
    refute user.password_expired?
    user.save
    assert user.password_changed_at.present?
    refute user.password_change_requested?
    refute user.password_expired?
  end

  test 'updating a record updates the time the password was changed if the password is changed' do
    user = User.create email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1'
    user.expire_password!
    assert user.password_change_requested?
    user.password = "NewPassword1"
    user.password_confirmation = "NewPassword1"
    user.save
    assert user.previous_changes.key?(:password_changed_at)
    refute user.password_change_requested?
  end

  test 'updating a record does not updates the time the password was changed if the password was not changed' do
    user = User.create email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1'
    user.expire_password!
    assert user.password_change_requested?
    user.save
    refute user.previous_changes.key?(:password_changed_at)
    assert user.password_change_requested?
  end

  test 'override expire after at runtime' do
    user = User.create email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1'
    user.instance_eval do
      def expire_password_after
        4.months
      end
    end
    user.password_changed_at = Time.now.ago(3.months)
    refute user.need_change_password?
    refute user.password_expired?
    user.password_changed_at = Time.now.ago(5.months)
    assert user.need_change_password?
    assert user.password_expired?
  end
end
