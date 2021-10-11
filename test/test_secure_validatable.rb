# frozen_string_literal: true

require 'test_helper'
require 'rails_email_validator'

class TestSecureValidatable < ActiveSupport::TestCase
  class User < ApplicationRecord
    devise :database_authenticatable, :password_archivable,
           :paranoid_verification, :password_expirable, :secure_validatable
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid
  end

  test 'email cannot be blank' do
    msg = "Email can't be blank"
    user = User.create password: 'passWord1', password_confirmation: 'passWord1'

    assert_equal(false, user.valid?)
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) do
      user.save!
    end
  end

  test 'email must be valid' do
    msg = 'Email is invalid'
    user = User.create email: 'bob', password: 'passWord1', password_confirmation: 'passWord1'
    assert_equal(false, user.valid?)
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) do
      user.save!
    end
  end

  test 'validate both email and password' do
    msgs = ['Email is invalid', 'Password must contain at least one upper-case letter']
    user = User.create email: 'bob@@foo.tv', password: 'password1', password_confirmation: 'password1'
    assert_equal(false, user.valid?)
    assert_equal(msgs, user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password must have capital letter' do
    msgs = ['Password must contain at least one upper-case letter']
    user = User.create email: 'bob@microsoft.com', password: 'password1', password_confirmation: 'password1'
    assert_equal(false, user.valid?)
    assert_equal(msgs, user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password must have lowercase letter' do
    msg = 'Password must contain at least one lower-case letter'
    user = User.create email: 'bob@microsoft.com', password: 'PASSWORD1', password_confirmation: 'PASSWORD1'
    assert_equal(false, user.valid?)
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password must have number' do
    msg = 'Password must contain at least one digit'
    user = User.create email: 'bob@microsoft.com', password: 'PASSword', password_confirmation: 'PASSword'
    assert_equal(false, user.valid?)
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password must have minimum length' do
    msg = 'Password is too short (minimum is 7 characters)'
    user = User.create email: 'bob@microsoft.com', password: 'Pa3zZ', password_confirmation: 'Pa3zZ'
    assert_equal(false, user.valid?)
    assert_equal([msg], user.errors.full_messages)
    assert_raises(ORMInvalidRecordException) { user.save! }
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
    assert_equal DEVISE_ORM == :active_record ? ['Email has already been taken'] : ['Email is already taken'], user.errors.full_messages
  end

  test 'password can not equal email for new user' do
    msg = 'Password must be different than the email.'
    user = User.create email: 'bob@microsoft.com', password: 'bob@microsoft.com', password_confirmation: 'bob@microsoft.com'
    refute user.valid?
    assert_includes(user.errors.full_messages, msg)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password can not equal case sensitive version of email for new user' do
    msg = 'Password must be different than the email.'
    user = User.create email: 'bob@microsoft.com', password: 'BoB@microsoft.com', password_confirmation: 'BoB@microsoft.com'
    refute user.valid?
    assert_includes(user.errors.full_messages, msg)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password can not equal email with spaces for new user' do
    msg = 'Password must be different than the email.'
    user = User.create email: 'bob@microsoft.com', password: 'bob@microsoft.com    ', password_confirmation: 'bob@microsoft.com    '
    refute user.valid?
    assert_includes(user.errors.full_messages, msg)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password can not equal case sensitive version of email with spaces for new user' do
    msg = 'Password must be different than the email.'
    user = User.create email: 'bob@microsoft.com', password: '  BoB@microsoft.com   ', password_confirmation: '  BoB@microsoft.com   '
    refute user.valid?
    assert_includes(user.errors.full_messages, msg)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password can not equal email for existing user' do
    user = User.create email: 'bob@microsoft.com', password: 'pAs5W0rd!Is5e6Ure', password_confirmation: 'pAs5W0rd!Is5e6Ure'

    msg = 'Password must be different than the email.'
    user.password = 'bob@microsoft.com'
    user.password_confirmation = 'bob@microsoft.com'
    refute user.valid?
    assert_includes(user.errors.full_messages, msg)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password can not equal case sensitive version of email for existing user' do
    user = User.create email: 'bob@microsoft.com', password: 'pAs5W0rd!Is5e6Ure', password_confirmation: 'pAs5W0rd!Is5e6Ure'

    msg = 'Password must be different than the email.'
    user.password = 'BoB@microsoft.com'
    user.password_confirmation = 'BoB@microsoft.com'
    refute user.valid?
    assert_includes(user.errors.full_messages, msg)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end

  test 'password can not equal email with spaces for existing user' do
    user = User.create email: 'bob@microsoft.com', password: 'pAs5W0rd!Is5e6Ure', password_confirmation: 'pAs5W0rd!Is5e6Ure'

    msg = 'Password must be different than the email.'
    user.password = 'bob@microsoft.com     '
    user.password_confirmation = 'bob@microsoft.com     '
    refute user.valid?
    assert_includes(user.errors.full_messages, msg)
    assert_raises(ORMInvalidRecordException) { user.save! }

    # User#email_not_equal_password_validation was raising
    # `NoMethodError (undefined method `downcase' for nil:NilClass)`
    # with a `nil` email.
    user.email = nil
    refute user.valid?
  end

  test 'password can not equal case sensitive version of email with spaces for existing user' do
    user = User.create email: 'bob@microsoft.com', password: 'pAs5W0rd!Is5e6Ure', password_confirmation: 'pAs5W0rd!Is5e6Ure'

    msg = 'Password must be different than the email.'
    user.password = ' BoB@microsoft.com      '
    user.password_confirmation = ' BoB@microsoft.com      '
    refute user.valid?
    assert_includes(user.errors.full_messages, msg)
    assert_raises(ORMInvalidRecordException) { user.save! }
  end
end
