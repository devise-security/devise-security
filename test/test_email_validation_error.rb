# frozen_string_literal: true

require 'test_helper'

class TestEmailValidationError < ActiveSupport::TestCase
  # Requirements:
  # 1. When email_validation is enabled but no EmailValidator class exists,
  #    users get a clear, actionable error (not cryptic NameError).
  # 2. When EmailValidator is defined, validation works normally.
  # 3. When email_validation is disabled, no EmailValidator is needed.

  # Model without :validatable so we can test secure_validatable's email
  # validation in isolation (Devise's :validatable adds its own email check).
  class SecureOnlyUser < ApplicationUserRecord
    devise :database_authenticatable, :secure_validatable
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid
  end

  test 'raises clear error when email_validation enabled but EmailValidator missing' do
    original_klass = Object.send(:remove_const, :EmailValidator)

    begin
      user = SecureOnlyUser.new(
        email: generate_unique_email,
        password: 'Password1!',
        password_confirmation: 'Password1!'
      )

      error = assert_raises(RuntimeError) { user.valid? }
      assert_match(/email_validation is enabled/, error.message)
      assert_match(/EmailValidator/, error.message)
      assert_match(/config\.email_validation = false/, error.message)
    ensure
      Object.const_set(:EmailValidator, original_klass)
    end
  end

  test 'validates email normally when EmailValidator is defined' do
    assert defined?(::EmailValidator), 'Expected EmailValidator from rails_email_validator gem'

    valid_user = SecureOnlyUser.new(
      email: 'valid@example.com',
      password: 'Password1!',
      password_confirmation: 'Password1!'
    )

    assert_predicate valid_user, :valid?

    invalid_user = SecureOnlyUser.new(
      email: 'not-an-email',
      password: 'Password1!',
      password_confirmation: 'Password1!'
    )

    assert_predicate invalid_user, :invalid?
    assert_includes invalid_user.errors.full_messages, 'Email is invalid'
  end

  test 'skips email validation when email_validation is false' do
    swap(Devise, email_validation: false) do
      user = SecureOnlyUser.new(
        email: 'not-a-valid-email',
        password: 'Password1!',
        password_confirmation: 'Password1!'
      )

      assert_predicate user, :valid?, "Expected valid when email_validation is false, got: #{user.errors.full_messages}"
    end
  end
end
