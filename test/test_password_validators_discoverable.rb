# frozen_string_literal: true

require 'test_helper'

# Tests for GitHub issue #441: validators_on(:password) discoverability.
#
# REQUIREMENT: Application code (e.g., Vulcan's password policy UI) needs to
# introspect password validators via `User.validators_on(:password)` to discover
# what rules are active. The v0.17 move to `validate do` blocks broke this
# because block validators don't register against specific attributes.
#
# After the fix, `validators_on(:password)` must return both the LengthValidator
# and the PasswordComplexityValidator (or whichever class is configured).
class TestPasswordValidatorsDiscoverable < ActiveSupport::TestCase
  class User < ApplicationUserRecord
    devise :database_authenticatable, :secure_validatable
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid
  end

  test 'validators_on(:password) includes a length validator' do
    length_validators = User.validators_on(:password).select do |v|
      v.is_a?(DeviseSecurity::PasswordLengthValidator) ||
        v.is_a?(ActiveModel::Validations::LengthValidator)
    end

    assert_not_empty length_validators,
                     'Expected validators_on(:password) to include a length validator'
  end

  test 'validators_on(:password) includes a complexity validator' do
    complexity_validators = User.validators_on(:password).select do |v|
      v.is_a?(DeviseSecurity::PasswordComplexityDelegator) ||
        v.is_a?(DeviseSecurity::PasswordComplexityValidator)
    end

    assert_not_empty complexity_validators,
                     'Expected validators_on(:password) to include a complexity validator'
  end

  test 'LengthValidator still enforces minimum length' do
    user = User.new(
      email: generate_unique_email,
      password: 'Pa1!',
      password_confirmation: 'Pa1!'
    )

    assert_predicate user, :invalid?
    assert user.errors[:password].any? { |msg| msg.include?('too short') },
           "Expected 'too short' error, got: #{user.errors[:password]}"
  end

  test 'PasswordComplexityValidator still enforces complexity rules' do
    user = User.new(
      email: generate_unique_email,
      password: 'password',
      password_confirmation: 'password'
    )

    assert_predicate user, :invalid?
    assert user.errors[:password].any? { |msg| msg.include?('upper-case') || msg.include?('digit') },
           "Expected complexity error, got: #{user.errors[:password]}"
  end

  test 'validators respect password_required? condition (persisted user without password change)' do
    user = User.create!(
      email: generate_unique_email,
      password: 'Password1!',
      password_confirmation: 'Password1!'
    )

    # Persisted user with no password change should be valid
    user.email = generate_unique_email

    assert_predicate user, :valid?, "Expected persisted user without password change to be valid, got: #{user.errors.full_messages}"
  end

  test 'dynamic password_length override still works at instance level' do
    user = User.new(
      email: generate_unique_email,
      password: 'Pa1!xxxx',
      password_confirmation: 'Pa1!xxxx'
    )

    # Should be valid with default length (7..128)
    assert_predicate user, :valid?, "Expected valid with default length, got: #{user.errors.full_messages}"

    # Override to require 20+ chars
    user.define_singleton_method(:password_length) { 20..128 }

    assert_predicate user, :invalid?, 'Expected invalid with overridden length of 20..128'
    assert user.errors[:password].any? { |msg| msg.include?('too short') },
           "Expected 'too short' error with overridden length"
  end

  test 'dynamic password_complexity override still works at instance level' do
    user = User.new(
      email: generate_unique_email,
      password: 'Password1',
      password_confirmation: 'Password1'
    )

    # Valid with default complexity (upper:1, lower:1, digit:1)
    assert_predicate user, :valid?, "Expected valid with default complexity, got: #{user.errors.full_messages}"

    # Override to require 5 symbols
    user.define_singleton_method(:password_complexity) { { symbol: 5 } }

    assert_predicate user, :invalid?, 'Expected invalid with overridden complexity requiring 5 symbols'
  end
end
