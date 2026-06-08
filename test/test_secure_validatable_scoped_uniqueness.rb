# frozen_string_literal: true

require 'test_helper'

# Tests for GitHub issue #448: scoped uniqueness validation conflict.
#
# When a model defines `validates :email, uniqueness: { scope: :some_column }`
# BEFORE including secure_validatable, the gem's `uniqueness_validation_of_login?`
# check must detect that validator and skip adding its own. Otherwise two
# uniqueness validators on the same attribute with different scopes cause
# conflicts.
#
# These tests are ActiveRecord-only because they rely on self.table_name and
# scoped uniqueness with a :username column that only exists in the AR schema.
if DEVISE_ORM == :active_record
  class TestSecureValidatableScopedUniqueness < ActiveSupport::TestCase
    # Model with a scoped uniqueness validator defined BEFORE devise.
    class ScopedUniquenessUser < ApplicationRecord
      self.table_name = 'users'

      validates :email, uniqueness: { scope: :username }

      devise :database_authenticatable, :secure_validatable
    end

    # Model with NO pre-existing uniqueness validator on email.
    class NoUniquenessUser < ApplicationRecord
      self.table_name = 'users'

      devise :database_authenticatable, :secure_validatable
    end

    # Model with an unscoped uniqueness validator already defined.
    class UnscopedUniquenessUser < ApplicationRecord
      self.table_name = 'users'

      validates :email, uniqueness: true

      devise :database_authenticatable, :secure_validatable
    end

    # Helper: count uniqueness validators on :email for a given model class.
    def uniqueness_validator_count(klass)
      klass.validators.count { |v| v.is_a?(ActiveRecord::Validations::UniquenessValidator) && v.attributes.include?(:email) }
    end

    test 'model with no pre-existing uniqueness validator gets one from secure_validatable' do
      assert_equal 1, uniqueness_validator_count(NoUniquenessUser),
                   'secure_validatable should add exactly one uniqueness validator on email'
    end

    test 'model with unscoped uniqueness validator does not get a duplicate' do
      assert_equal 1, uniqueness_validator_count(UnscopedUniquenessUser),
                   'secure_validatable should skip adding a uniqueness validator when one already exists (unscoped)'
    end

    test 'model with scoped uniqueness validator does not get a duplicate (issue #448)' do
      assert_equal 1, uniqueness_validator_count(ScopedUniquenessUser),
                   'secure_validatable should skip adding a uniqueness validator when a scoped one already exists'
    end

    test 'scoped uniqueness validator preserves its original scope' do
      validator = ScopedUniquenessUser.validators.find { |v| v.is_a?(ActiveRecord::Validations::UniquenessValidator) && v.attributes.include?(:email) }

      scope = Array(validator.options[:scope])

      assert_includes scope, :username,
                      'the original scoped validator should be preserved with its scope intact'
    end
  end
end
