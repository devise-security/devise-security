# frozen_string_literal: true

require 'test_helper'

class TestSecureValidatableAuthKeyUsername < ActiveSupport::TestCase
  class User < ApplicationRecord
    devise authentication_keys: [:username]

    devise :database_authenticatable, :secure_validatable
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid

    protected

    def validate_email_uniqueness?
      false
    end
  end

  test "new user can use an existing user's email if validate_email_uniqueness? is set to false" do
    User.create!(
      username: 'bobber1',
      email: 'bob@microsoft.com',
      password: 'Passw-!88dsSdd-@ord1!',
      password_confirmation: 'Passw-!88dsSdd-@ord1!'
    )

    user = User.new(
      username: 'bobber2',
      email: 'bob@microsoft.com',
      password: 'Passw-!88dsSdd-@ord1!',
      password_confirmation: 'Passw-!88dsSdd-@ord1!'
    )

    assert_predicate user, :valid?
  end

  test 'username uniqueness is validated' do
    User.create!(
      username: 'bobber',
      email: 'bob@microsoft.com',
      password: 'Passw-!88dsSdd-@ord1!',
      password_confirmation: 'Passw-!88dsSdd-@ord1!'
    )

    user = User.new(
      username: 'bobber',
      email: 'bob@microsoft.com',
      password: 'Passw-!88dsSdd-@ord1!',
      password_confirmation: 'Passw-!88dsSdd-@ord1!'
    )

    assert_predicate user, :invalid?
    assert_equal(['Username has already been taken'], user.errors.full_messages)
  end
end
