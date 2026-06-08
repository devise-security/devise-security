# frozen_string_literal: true

require 'test_helper'

# REQUIREMENTS (upstream issue #351):
# - SecureValidatable must handle Hash-style authentication_keys (e.g., { email: true })
#   the same way Devise core does (via respond_to?(:keys) normalization).
# - When authentication_keys is empty, SecureValidatable must raise a clear error
#   at class load time — not a cryptic nil crash at runtime.
#
# These tests use anonymous classes with table_name, which is AR-only.
if DEVISE_ORM == :active_record
  class TestSecureValidatableHashAuthKeys < ActiveSupport::TestCase
    test 'login_attribute handles Hash-style authentication_keys' do
      klass = Class.new(ApplicationRecord) do
        self.table_name = 'users'
        devise :database_authenticatable, :secure_validatable,
               authentication_keys: { email: true }
      end

      # Should not crash — login_attribute should return :email
      assert_equal :email, klass.send(:login_attribute)
    end

    # NOTE: Devise itself overrides empty authentication_keys with its default
    # [:email], so empty keys cannot actually reach SecureValidatable in
    # practice. The guard in login_attribute is defensive — if somehow empty
    # keys do arrive, a clear error is raised instead of a nil crash.
    test 'login_attribute raises clear error if authentication_keys is somehow empty' do
      klass = Class.new(ApplicationRecord) do
        self.table_name = 'users'
        devise :database_authenticatable, :secure_validatable
      end

      # Force empty keys to test the guard clause
      klass.instance_variable_set(:@authentication_keys, [])
      error = assert_raises(RuntimeError) do
        klass.send(:login_attribute)
      end

      assert_match(/authentication_keys/, error.message)
      assert_match(/SecureValidatable/, error.message)
    end

    test 'uniqueness scope handles Hash-style authentication_keys with multiple keys' do
      # With { email: true, username: false }, scope should be [:username]
      klass = Class.new(ApplicationRecord) do
        self.table_name = 'users'
        devise :database_authenticatable, :secure_validatable,
               authentication_keys: { email: true, username: false }
      end

      assert_equal :email, klass.send(:login_attribute)
    end
  end
end
