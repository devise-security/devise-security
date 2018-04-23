# frozen_string_literal: true

require 'test_helper'

class TestPasswordArchivable < ActiveSupport::TestCase
  setup do
    Devise.expire_password_after = 2.month
  end

  teardown do
    Devise.expire_password_after = 90.days
  end

  test 'password expires' do
    user = User.create email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1'
    refute user.need_change_password?

    user.update(password_changed_at: Time.now.ago(3.month))
    assert user.need_change_password?
  end

  test 'override expire after at runtime' do
    user = User.new email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1'
    user.instance_eval do
      def expire_password_after
        4.month
      end
    end
    user.password_changed_at = Time.now.ago(3.month)
    refute user.need_change_password?
    user.password_changed_at = Time.now.ago(5.month)
    assert user.need_change_password?
  end
end
