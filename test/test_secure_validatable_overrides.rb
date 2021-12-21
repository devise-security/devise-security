# frozen_string_literal: true

require 'test_helper'

class TestSecureValidatableOverrides < ActiveSupport::TestCase
  class User < ApplicationRecord
    devise :database_authenticatable, :secure_validatable
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid
  end

  class ClassLevelOverrideUser < User
    self.password_complexity = { symbol: 1 }
    self.password_length = 10..100
  end

  class InstanceLevelOverrideUser < User
    def password_complexity
      { symbol: 2 }
    end

    def password_length
      11..100
    end
  end

  test 'password complexity can be overridden at the class level' do
    user = ClassLevelOverrideUser.new(
      email: 'bob@microsoft.com',
      password: 'PASSwordddd',
      password_confirmation: 'PASSwordddd'
    )

    assert user.invalid?
    assert_equal(
      ['Password must contain at least one punctuation mark or symbol'],
      user.errors.full_messages
    )
  end

  test 'password complexity can be overridden at the instance level' do
    user = InstanceLevelOverrideUser.new(
      email: 'bob@microsoft.com',
      password: 'PASSwordddd',
      password_confirmation: 'PASSwordddd'
    )

    assert user.invalid?
    assert_equal(
      ['Password must contain at least 2 punctuation marks or symbols'],
      user.errors.full_messages
    )
  end

  test 'password length can be overridden at the class level' do
    user = ClassLevelOverrideUser.new(
      email: 'bob@microsoft.com',
      password: 'Pa3zZ1!',
      password_confirmation: 'Pa3zZ1!'
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
      password: 'Pa3zZ1!!',
      password_confirmation: 'Pa3zZ1!!'
    )

    assert user.invalid?
    assert_equal(
      ['Password is too short (minimum is 11 characters)'],
      user.errors.full_messages
    )
  end
end
