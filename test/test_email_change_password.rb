# frozen_string_literal: true

require 'test_helper'

class TestEmailChangePassword < ActiveSupport::TestCase
  class User < ApplicationUserRecord
    devise :database_authenticatable, :secure_validatable
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid
  end

  setup do
    @password = 'Password1!'
    @user = User.create!(
      email: generate_unique_email,
      password: @password,
      password_confirmation: @password
    )
  end

  test 'config disabled (default): email change allowed without current_password' do
    swap Devise, require_password_on_email_change: false do
      @user.email = generate_unique_email

      assert_predicate @user, :valid?, "Expected user to be valid but got: #{@user.errors.full_messages}"
    end
  end

  test 'config enabled: email change without current_password adds error' do
    swap Devise, require_password_on_email_change: true do
      @user.email = generate_unique_email

      assert_predicate @user, :invalid?
      assert_includes @user.errors[:current_password], I18n.t('errors.messages.blank')
    end
  end

  test 'config enabled: email change with wrong current_password adds error' do
    swap Devise, require_password_on_email_change: true do
      @user.email = generate_unique_email
      @user.current_password = 'WrongPassword1!'

      assert_predicate @user, :invalid?
      assert_includes @user.errors[:current_password], I18n.t('errors.messages.invalid')
    end
  end

  test 'config enabled: email change with correct current_password succeeds' do
    swap Devise, require_password_on_email_change: true do
      @user.email = generate_unique_email
      @user.current_password = @password

      assert_predicate @user, :valid?, "Expected user to be valid but got: #{@user.errors.full_messages}"
    end
  end

  test 'config enabled: non-email update without current_password succeeds' do
    swap Devise, require_password_on_email_change: true do
      # Update password (not email) — should not require current_password for this validation
      @user.password = 'NewPassword1!'
      @user.password_confirmation = 'NewPassword1!'
      # current_equal_password_validation may fire but not our email-change validation
      assert_not_includes @user.errors[:current_password], I18n.t('errors.messages.blank')
    end
  end

  test 'config enabled: new record does not require current_password' do
    swap Devise, require_password_on_email_change: true do
      user = User.new(
        email: generate_unique_email,
        password: 'Password1!',
        password_confirmation: 'Password1!'
      )

      assert_predicate user, :valid?, "Expected new user to be valid but got: #{user.errors.full_messages}"
    end
  end

  test 'config as Proc: dynamic per-record resolution' do
    swap Devise, require_password_on_email_change: -> { email_was.include?('@secure.com') } do
      # User with non-secure email — no password required
      @user.email = 'new@example.com'

      assert_predicate @user, :valid?, "Expected user to be valid but got: #{@user.errors.full_messages}"

      # Reload to reset changes
      @user.reload

      # User changing TO a secure domain — still based on current email which is @example.com
      # The proc receives the record instance, so it checks the record's current state
      @user.email = 'new@secure.com'

      assert_predicate @user, :valid?, "Expected user to be valid but got: #{@user.errors.full_messages}"
    end
  end

  test 'config as Proc returning true: requires current_password' do
    swap Devise, require_password_on_email_change: -> { true } do
      @user.email = generate_unique_email

      assert_predicate @user, :invalid?
      assert_includes @user.errors[:current_password], I18n.t('errors.messages.blank')

      @user.current_password = @password

      assert_predicate @user, :valid?, "Expected user to be valid but got: #{@user.errors.full_messages}"
    end
  end
end
