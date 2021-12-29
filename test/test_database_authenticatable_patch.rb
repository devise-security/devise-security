# frozen_string_literal: true

require 'test_helper'

class TestDatabaseAuthenticatablePatch < ActiveSupport::TestCase
  def create_user
    User.create(
      email: 'bob@microsoft.com',
      password: 'Password1!',
      password_confirmation: 'Password1!'
    ) do |user|
      user.extend(Devise::Models::DatabaseAuthenticatablePatch)
    end
  end

  test 'updates if all params are present and valid' do
    user = create_user

    assert(
      user.update_with_password(
        {
          current_password: 'Password1!',
          password: 'Password2!',
          password_confirmation: 'Password2!'
        }
      )
    )
  end

  test 'does not update if current_password is missing' do
    user = create_user

    user.update_with_password(
      {
        password: 'Password2!',
        password_confirmation: 'Password2!'
      }
    )

    assert_equal(["Current password can't be blank"], user.errors.full_messages)
  end

  test 'does not update if current_password is incorrect' do
    user = create_user

    user.update_with_password(
      {
        current_password: 'Password2!',
        password: 'Password2!',
        password_confirmation: 'Password2!'
      }
    )

    assert_equal(['Current password is invalid'], user.errors.full_messages)
  end

  test 'does not update if password is missing' do
    user = create_user

    user.update_with_password(
      {
        current_password: 'Password1!',
        password: '',
        password_confirmation: 'Password2!'
      }
    )

    assert_equal(["Password can't be blank"], user.errors.full_messages)
  end

  test 'does not update if password is invalid and mismatches confirmation' do
    user = create_user

    user.update_with_password(
      {
        current_password: 'Password1!',
        password: 'f',
        password_confirmation: 'Password2!'
      }
    )

    assert_equal(
      [
        "Password confirmation doesn't match Password",
        'Password is too short (minimum is 7 characters)',
        'Password must contain at least one digit',
        'Password must contain at least one upper-case letter'
      ],
      user.errors.full_messages
    )
  end

  test 'does not update if password is invalid and matches confirmation' do
    user = create_user

    user.update_with_password(
      {
        current_password: 'Password1!',
        password: 'f',
        password_confirmation: 'f'
      }
    )

    assert_equal(
      [
        'Password is too short (minimum is 7 characters)',
        'Password must contain at least one digit',
        'Password must contain at least one upper-case letter'
      ],
      user.errors.full_messages
    )
  end

  test 'does not update if password_confirmation is missing' do
    user = create_user

    user.update_with_password(
      {
        current_password: 'Password1!',
        password: 'Password2!',
        password_confirmation: ''
      }
    )

    assert_equal(
      ["Password confirmation can't be blank"], user.errors.full_messages
    )
  end

  test 'does not update if password_confirmation is mismatched' do
    user = create_user

    user.update_with_password(
      {
        current_password: 'Password1!',
        password: 'Password2!',
        password_confirmation: 'Password3!'
      }
    )

    assert_equal(
      ["Password confirmation doesn't match Password"],
      user.errors.full_messages
    )
  end
end
