# frozen_string_literal: true

require 'test_helper'

class TestSecureValidatableOverrides < ActiveSupport::TestCase
  class ::CustomClassPasswordValidator < DeviseSecurity::PasswordComplexityValidator
    def patterns
      super.merge(letter: /\p{Alpha}/)
    end
  end

  class ::CustomInstancePasswordValidator < DeviseSecurity::PasswordComplexityValidator
    # Add a pattern for alphanumeric characters. See
    # [en.yml](file:///./test/dummy/config/locales/en.yml) for translations used in
    # tests.
    def patterns
      super.merge(alnum: /\p{Alnum}/)
    end
  end

  class User < ApplicationRecord
    devise :database_authenticatable, :secure_validatable
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid
  end

  class ClassLevelOverrideUser < User
    self.allow_passwords_equal_to_email = true
    self.email_validation = false
    self.password_complexity = { symbol: 1, letter: 1 }
    self.password_complexity_validator = 'custom_class_password_validator'
    self.password_length = 10..100
  end

  class InstanceLevelOverrideUser < ClassLevelOverrideUser
    def allow_passwords_equal_to_email
      true
    end

    def email_validation
      false
    end

    def password_complexity
      { symbol: 2, alnum: 1 }
    end

    def password_length
      11..100
    end

    def password_complexity_validator
      'CustomInstancePasswordValidator'
    end
  end

  test 'email equal to password can be overridden at the class level' do
    user = ClassLevelOverrideUser.new(
      email: 'bob1!@microsoft.com',
      password: 'bob1!@microsoft.com',
      password_confirmation: 'bob1!@microsoft.com'
    )

    assert user.valid?
  end

  test 'email equal to password can be overridden at the instance level' do
    user = InstanceLevelOverrideUser.new(
      email: 'bob1!@microsoft.com',
      password: 'bob1!@microsoft.com',
      password_confirmation: 'bob1!@microsoft.com'
    )

    assert user.valid?
  end

  test 'email validation can be overridden at the class level' do
    user = ClassLevelOverrideUser.new(
      email: 'bob1!@f.com',
      password: 'Pa3zZ1!!aaaaaa',
      password_confirmation: 'Pa3zZ1!!aaaaaa'
    )

    assert user.valid?
  end

  test 'email validation can be overridden at the instance level' do
    user = InstanceLevelOverrideUser.new(
      email: 'bob1!@f.com',
      password: 'Pa3zZ1!!aaaaaa',
      password_confirmation: 'Pa3zZ1!!aaaaaa'
    )

    assert user.valid?
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

  test 'password validator can be overridden at the instance level' do
    password = '!' * 11 # 11 characters, all symbols
    user = InstanceLevelOverrideUser.new(
      email: 'bob@microsoft.com',
      password: password,
      password_confirmation: password
    )

    assert user.invalid?
    # This validation error only occurs when the CustomInstancePasswordValidator
    # is used.
    assert_equal(
      ['Password must contain at least one letter or number'],
      user.errors.full_messages
    )
  end

  test 'password validator can be overridden at the class level' do
    password = '!' * 10 # 10 characters, all symbols
    user = ClassLevelOverrideUser.new(
      email: 'bob@microsoft.com',
      password: password,
      password_confirmation: password
    )

    assert user.invalid?
    # This validation error only occurs when the CustomClassPasswordValidator
    # is used.
    assert_equal(
      ['Password must contain at least one letter'],
      user.errors.full_messages
    )
  end
end
