# frozen_string_literal: true

require 'test_helper'

class TestSecureValidatableOverrides < ActiveSupport::TestCase
  class User < ApplicationRecord
    devise :database_authenticatable, :secure_validatable
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid
  end

  class ClassLevelOverrideUser < User
    self.password_length = 10..100
  end

  class InstanceLevelOverrideUser < ClassLevelOverrideUser
    def password_length
      11..100
    end
  end

  test 'password length can be overridden at the class level' do
    user = ClassLevelOverrideUser.new(
      email: 'bob@microsoft.com',
      password: 'Pa3zZ',
      password_confirmation: 'Pa3zZ'
    )

    assert user.invalid?
    assert_equal(
      ['Password is too short (minimum is 10 characters)'],
      user.errors.full_messages
    )
  end

  test 'password length can be overridden at the instance level' do
    user = InstanceLevelOverrideUser.new(
      email: 'bob@microsoft.com',
      password: 'Pa3zZ',
      password_confirmation: 'Pa3zZ'
    )

    assert user.invalid?
    assert_equal(
      ['Password is too short (minimum is 11 characters)'],
      user.errors.full_messages
    )
  end
end
