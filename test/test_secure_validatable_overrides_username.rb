# frozen_string_literal: true

require 'test_helper'

class TestSecureValidatableOverridesUsername < ActiveSupport::TestCase
  include IntegrationHelpers

  class User < ApplicationRecord
    devise authentication_keys: [:username]
    devise :database_authenticatable, :secure_validatable, skip_email_uniqueness_validation: true
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid
  end

  test "new user can use existing user's email if skip_email_uniqueness_validation" do
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
end
