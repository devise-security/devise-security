# frozen_string_literal: true

require 'test_helper'

class TestSecureValidatable < ActiveSupport::TestCase
  class User < ApplicationRecord
    devise :database_authenticatable, :secure_validatable
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid
  end

  class EmailNotRequiredUser < User
    protected

    def email_required?
      false
    end
  end

  test 'email cannot be blank upon creation' do
    user = User.new(
      password: 'Password1!', password_confirmation: 'Password1!'
    )

    assert user.invalid?
    assert_equal(["Email can't be blank"], user.errors.full_messages)
  end

  test 'email can be blank upon creation if email not required' do
    user = EmailNotRequiredUser.new(
      password: 'Password1!', password_confirmation: 'Password1!'
    )

    assert user.valid?
  end

  test 'email cannot be updated to be blank' do
    user = User.new(
      email: 'bob@microsoft.com',
      password: 'Password1!',
      password_confirmation: 'Password1!'
    )

    assert user.valid?

    user.email = nil

    assert user.invalid?
    assert_equal(["Email can't be blank"], user.errors.full_messages)
  end

  test 'email can be updated to be blank if email not required' do
    user = EmailNotRequiredUser.new(
      email: 'bob@microsoft.com',
      password: 'Password1!',
      password_confirmation: 'Password1!'
    )

    assert user.valid?

    user.email = nil

    assert user.valid?
  end

  test 'email must be valid' do
    user = User.new(
      email: 'bob', password: 'Password1!', password_confirmation: 'Password1!'
    )

    assert user.invalid?
    assert_equal(['Email is invalid'], user.errors.full_messages)
  end

  test 'validate both email and password' do
    user = User.new(
      email: 'bob',
      password: 'password1!',
      password_confirmation: 'password1!'
    )

    assert user.invalid?
    assert_equal(
      [
        'Email is invalid',
        'Password must contain at least one upper-case letter'
      ],
      user.errors.full_messages
    )
  end

  test 'password cannot be blank upon creation' do
    user = User.new(email: 'bob@microsoft.com')

    msgs = ["Password can't be blank"]

    msgs << "Encrypted password can't be blank" if DEVISE_ORM == :mongoid

    assert user.invalid?
    assert_equal(msgs, user.errors.full_messages)
  end

  test 'password cannot be updated to be blank' do
    user = User.new(
      email: 'bob@microsoft.com',
      password: 'Password1!',
      password_confirmation: 'Password1!'
    )

    assert user.valid?

    user.password = nil
    user.password_confirmation = nil

    assert user.invalid?
    assert_equal(["Password can't be blank"], user.errors.full_messages)
  end

  test 'password_confirmation must match password' do
    user = User.new(
      email: 'bob@microsoft.com',
      password: 'Password1!',
      password_confirmation: 'not the same password'
    )

    assert user.invalid?
    assert_equal(
      ["Password confirmation doesn't match Password"],
      user.errors.full_messages
    )
  end

  test 'password_confirmation cannot be blank' do
    user = User.new(
      email: 'bob@microsoft.com',
      password: 'Password1!',
      password_confirmation: ''
    )

    assert user.invalid?
    assert_equal(
      ["Password confirmation doesn't match Password"],
      user.errors.full_messages
    )
  end

  test 'password_confirmation can be skipped' do
    user = User.new(
      email: 'bob@microsoft.com',
      password: 'Password1!',
      password_confirmation: nil
    )

    assert user.valid?
  end

  test 'password must have capital letter' do
    user = User.new(
      email: 'bob@microsoft.com',
      password: 'password1',
      password_confirmation: 'password1'
    )

    assert user.invalid?
    assert_equal(
      ['Password must contain at least one upper-case letter'],
      user.errors.full_messages
    )
  end

  test 'password must have lowercase letter' do
    user = User.new(
      email: 'bob@microsoft.com',
      password: 'PASSWORD1',
      password_confirmation: 'PASSWORD1'
    )

    assert user.invalid?
    assert_equal(
      ['Password must contain at least one lower-case letter'],
      user.errors.full_messages
    )
  end

  test 'password must have number' do
    user = User.new(
      email: 'bob@microsoft.com',
      password: 'PASSword',
      password_confirmation: 'PASSword'
    )

    assert user.invalid?
    assert_equal(
      ['Password must contain at least one digit'],
      user.errors.full_messages
    )
  end

  test 'password must meet minimum length' do
    user = User.new(
      email: 'bob@microsoft.com',
      password: 'Pa3zZ',
      password_confirmation: 'Pa3zZ'
    )

    assert user.invalid?
    assert_equal(
      ['Password is too short (minimum is 7 characters)'],
      user.errors.full_messages
    )
  end

  test "new user can't use existing user's email" do
    options = {
      email: 'bob@microsoft.com',
      password: 'Password1!',
      password_confirmation: 'Password1!'
    }
    User.create!(options)
    user = User.new(options)

    assert user.invalid?
    if DEVISE_ORM == :active_record
      assert_equal(['Email has already been taken'], user.errors.full_messages)
    else
      assert_equal(['Email is already taken'], user.errors.full_messages)
    end
  end

  test "new user can't use existing user's email with different casing" do
    options = {
      email: 'bob@microsoft.com',
      password: 'Password1!',
      password_confirmation: 'Password1!'
    }
    User.create!(options)
    options[:email] = 'BOB@MICROSOFT.COM'
    user = User.new(options)

    assert user.invalid?
    if DEVISE_ORM == :active_record
      assert_equal(['Email has already been taken'], user.errors.full_messages)
    else
      assert_equal(['Email is already taken'], user.errors.full_messages)
    end
  end

  test 'password cannot equal email for new user' do
    user = User.new(
      email: 'Bob1@microsoft.com',
      password: 'Bob1@microsoft.com',
      password_confirmation: 'Bob1@microsoft.com'
    )

    assert user.invalid?
    assert_equal(
      ['Password must be different than the email.'],
      user.errors.full_messages
    )
  end

  test 'password cannot equal case sensitive version of email for new user' do
    user = User.new(
      email: 'bob1@microsoft.com',
      password: 'BoB1@microsoft.com',
      password_confirmation: 'BoB1@microsoft.com'
    )

    assert user.invalid?
    assert_equal(
      ['Password must be different than the email.'],
      user.errors.full_messages
    )
  end

  test 'password cannot equal email with spaces for new user' do
    user = User.new(
      email: 'Bob1@microsoft.com',
      password: 'Bob1@microsoft.com    ',
      password_confirmation: 'Bob1@microsoft.com    '
    )

    assert user.invalid?
    assert_equal(
      ['Password must be different than the email.'],
      user.errors.full_messages
    )
  end

  test 'password cannot equal case sensitive version of email with spaces '\
       'for new user' do
    user = User.new(
      email: 'Bob1@microsoft.com',
      password: '  boB1@microsoft.com   ',
      password_confirmation: '  boB1@microsoft.com   '
    )

    assert user.invalid?
    assert_equal(
      ['Password must be different than the email.'],
      user.errors.full_messages
    )
  end

  test 'new password cannot equal current password' do
    user = User.create(
      email: 'bob@microsoft.com',
      password: 'Password1!',
      password_confirmation: 'Password1!'
    )

    user.password = 'Password1!'

    assert user.invalid?
    assert_equal(
      ['Password must be different than the current password.'],
      user.errors.full_messages
    )
  end

  test 'should not be included in objects with invalid API' do
    error = assert_raise RuntimeError do
      class ::Dog; include Devise::Models::SecureValidatable; end
    end

    assert_equal('Could not use SecureValidatable on Dog', error.message)
  end
end
