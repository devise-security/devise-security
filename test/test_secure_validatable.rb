# frozen_string_literal: true

require 'test_helper'
require 'rails_email_validator'

class TestSecureValidatable < ActiveSupport::TestCase
  class User < ActiveRecord::Base
    devise :secure_validatable
  end

  # Some configurations can be overridden in subclasses
  class ModifiedUser < User
    def self.password_length
      10..128
    end

    def self.password_complexity
      { digit: 10 }
    end
  end

  test 'secure_validatable includes database_authenticatable' do
    assert User.devise_modules.include?(:database_authenticatable)
  end

  test 'email cannot be blank' do
    msg = "Email can't be blank"
    user = User.create password: 'passWord1', password_confirmation: 'passWord1'

    assert_equal(false, user.valid?)
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ActiveRecord::RecordInvalid) do
      user.save!
    end
  end

  test 'email must be valid' do
    msg = 'Email is invalid'
    user = User.create email: 'bob', password: 'passWord1', password_confirmation: 'passWord1'
    assert_equal(false, user.valid?)
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ActiveRecord::RecordInvalid) do
      user.save!
    end
  end

  test 'validate both email and password' do
    msgs = ['Email is invalid', 'Password must contain at least one uppercase letter']
    user = User.create email: 'bob@@foo.tv', password: 'password1', password_confirmation: 'password1'
    assert_equal(false, user.valid?)
    assert_equal(msgs, user.errors.full_messages)
    assert_raises(ActiveRecord::RecordInvalid) { user.save! }
  end

  test 'password must have capital letter' do
    msgs = ['Password must contain at least one uppercase letter']
    user = User.create email: 'bob@microsoft.com', password: 'password1', password_confirmation: 'password1'
    assert_equal(false, user.valid?)
    assert_equal(msgs, user.errors.full_messages)
    assert_raises(ActiveRecord::RecordInvalid) { user.save! }
  end

  test 'password must have lowercase letter' do
    msg = 'Password must contain at least one lowercase letter'
    user = User.create email: 'bob@microsoft.com', password: 'PASSWORD1', password_confirmation: 'PASSWORD1'
    assert_equal(false, user.valid?)
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ActiveRecord::RecordInvalid) { user.save! }
  end

  test 'password must have number' do
    msg = 'Password must contain at least one digit'
    user = User.create email: 'bob@microsoft.com', password: 'PASSword', password_confirmation: 'PASSword'
    assert_equal(false, user.valid?)
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ActiveRecord::RecordInvalid) { user.save! }
  end

  test 'subclasses can override complexity requirements' do
    msg = 'Password must contain at least 10 digits'
    user = ModifiedUser.create email: 'bob@microsoft.com', password: 'PASSwordPASSword', password_confirmation: 'PASSwordPASSword'
    assert_equal(false, user.valid?)
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ActiveRecord::RecordInvalid) { user.save! }
  end

  test 'password must have minimum length' do
    msg = 'Password is too short (minimum is 6 characters)'
    user = User.create email: 'bob@microsoft.com', password: 'Pa3zZ', password_confirmation: 'Pa3zZ'
    assert_equal(false, user.valid?)
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ActiveRecord::RecordInvalid) { user.save! }
  end

  test 'password length can be overridden in a subclass' do
    msg = 'Password is too short (minimum is 10 characters)'
    user = ModifiedUser.new email: 'bob@microsoft.com', password: 'Pa3zZ', password_confirmation: 'Pa3zZ'
    assert_equal(false, user.valid?)
    assert_includes(user.errors.full_messages, msg)
    assert_raises(ActiveRecord::RecordInvalid) { user.save! }
  end

  test 'duplicate email validation message is added only once' do
    options = {
      email: 'test@example.org',
      password: 'Test12345',
      password_confirmation: 'Test12345',
    }
    SecureUser.create!(options)
    user = SecureUser.new(options)
    refute user.valid?
    assert_equal ['Email has already been taken'], user.errors.full_messages
  end

  test 'cannot change password to be the same as the current one' do
    user = User.create!(email: 'bob@microsoft.com', password: 'Test12345', password_confirmation: 'Test12345')
    user.password = 'Test12345'
    user.password_confirmation = 'Test12345'
    refute user.valid?
    assert_equal ["Password must be different from the current password."], user.errors.full_messages
  end
end
