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
    user.need_change_password!
    refute user.need_change_password?
  end

  test 'password expires on demand' do
    Devise.expire_password_after = true
    user = User.create email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1'
    refute user.need_change_password?
    user.need_change_password!
    assert user.need_change_password?
  end

  test 'password expires' do
    user = User.create email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1'
    refute user.need_change_password?

    user.update(password_changed_at: Time.now.ago(3.months))
    assert user.need_change_password?
  end

  test 'saving a record records the time the password was changed' do
    user = User.new email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1'
    assert user.password_changed_at.nil?
    user.save
    refute user.password_changed_at.nil?
  end

  test 'override expire after at runtime' do
    user = User.new email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1'
    user.instance_eval do
      def expire_password_after
        4.months
      end
    end
    user.password_changed_at = Time.now.ago(3.months)
    refute user.need_change_password?
    user.password_changed_at = Time.now.ago(5.months)
    assert user.need_change_password?
  end
end
