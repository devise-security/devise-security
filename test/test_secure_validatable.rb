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
end
