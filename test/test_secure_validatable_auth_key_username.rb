# frozen_string_literal: true

require 'test_helper'

class TestSecureValidatableAuthKeyUsername < ActiveSupport::TestCase
  include IntegrationHelpers

  class User < ApplicationRecord
    devise authentication_keys: [:username]

    devise :database_authenticatable, :secure_validatable, skip_email_uniqueness_validation: true
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid
  end

  test "new user can use existing user's email if skip_email_uniqueness_validatio is set to true" do
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

    assert user.valid?
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

    assert user.invalid?
    assert_equal(["Username has already been taken"], user.errors.full_messages)
  end
end
