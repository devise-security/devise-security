# frozen_string_literal: true

require 'test_helper'
require 'rails_email_validator'

class TestSecureValidatable < ActiveSupport::TestCase
  class User < ApplicationRecord
    devise :database_authenticatable, :paranoid_verification,
      :password_expirable, :secure_validatable
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid
  end

  test 'email cannot be blank' do
    msg = "Email can't be blank"
    user = User.create password: 'passWord1', password_confirmation: 'passWord1'

    assert user.invalid?
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) do
      user.save!
    end
  end

  test 'email must be valid' do
    msg = 'Email is invalid'
    user = User.create email: 'bob', password: 'passWord1', password_confirmation: 'passWord1'
    assert user.invalid?
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) do
      user.save!
    end
  end

  test 'validate both email and password' do
    msgs = ['Email is invalid', 'Password must contain at least one uppercase letter']
    user = User.create email: 'bob@@foo.tv', password: 'password1', password_confirmation: 'password1'
    assert user.invalid?
    assert_equal(msgs, user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password must have capital letter' do
    msgs = ['Password must contain at least one uppercase letter']
    user = User.create email: 'bob@microsoft.com', password: 'password1', password_confirmation: 'password1'
    assert user.invalid?
    assert_equal(msgs, user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password must have lowercase letter' do
    msg = 'Password must contain at least one lowercase letter'
    user = User.create email: 'bob@microsoft.com', password: 'PASSWORD1', password_confirmation: 'PASSWORD1'
    assert user.invalid?
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password must have number' do
    msg = 'Password must contain at least one digit'
    user = User.create email: 'bob@microsoft.com', password: 'PASSword', password_confirmation: 'PASSword'
    assert user.invalid?
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'subclasses can override password complexity requirements' do
    class ModifiedUser < User
      def self.password_complexity
        { digits: 10 }
      end

      def password_complexity
        self.class.password_complexity
      end
    end

    msg = 'Password must contain at least 10 digits'
    user = ModifiedUser.create email: 'bob@microsoft.com', password: 'PASSwordPASSword', password_confirmation: 'PASSwordPASSword'
    assert user.invalid?
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'instances can override complexity requirements' do
    class ModifiedUser < User
      def password_complexity
        { digits: 15 }
      end
    end

    msg = 'Password must contain at least 15 digits'
    user = ModifiedUser.create email: 'bob@microsoft.com', password: 'PASSwordPASSword', password_confirmation: 'PASSwordPASSword'
    assert user.invalid?
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password must have minimum length' do
    msg = 'Password is too short (minimum is 7 characters)'
    user = User.create email: 'bob@microsoft.com', password: 'Pa3zZ', password_confirmation: 'Pa3zZ'
    assert user.invalid?
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password length can be overridden in a subclass' do
    class ModifiedUser < User
      def self.password_length
        10..20
      end

      def password_length
        self.class.password_length
      end
    end

    msg = 'Password is too short (minimum is 10 characters)'
    user = ModifiedUser.new email: 'bob@microsoft.com', password: 'Pa3zZ', password_confirmation: 'Pa3zZ'
    assert user.invalid?
    assert_includes(user.errors.full_messages, msg)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password length can be overridden by an instance' do
    class ModifiedUser < User
      def password_length
        15..20
      end
    end

    msg = 'Password is too short (minimum is 15 characters)'
    user = ModifiedUser.new email: 'bob@microsoft.com', password: 'Pa3zZ', password_confirmation: 'Pa3zZ'
    assert user.invalid?
    assert_includes(user.errors.full_messages, msg)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'email validation message is added only once' do
    options = {
      email: 'test@example.org',
      password: 'Test12345',
      password_confirmation: 'Test12345',
    }
    SecureUser.create!(options)
    user = SecureUser.new(options)
    assert user.invalid?
    assert_equal DEVISE_ORM == :active_record ? ['Email has already been taken'] : ['Email is already taken'], user.errors.full_messages
  end

  test 'cannot change password to be the same as the current one' do
    user = User.create!(email: 'bob@microsoft.com', password: 'Test12345', password_confirmation: 'Test12345')
    user.password = 'Test12345'
    user.password_confirmation = 'Test12345'
    assert user.invalid?
    assert_equal ['Password must be different from the current password.'], user.errors.full_messages
  end
end
