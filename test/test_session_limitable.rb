# frozen_string_literal: true

require 'test_helper'

class TestSessionLimitable < ActiveSupport::TestCase
  class ModifiedUser < User
    def skip_session_limitable?
      true
    end
  end

  test 'should have required_fields array' do
    assert_equal [:unique_session_id], Devise::Models::SessionLimitable.required_fields(User)
  end

  test 'check is not skipped by default' do
    user = User.new(email: generate_unique_email, password: 'password1', password_confirmation: 'password1')
    assert_not(user.skip_session_limitable?)
  end

  test 'default check can be overridden by record instance' do
    modified_user = ModifiedUser.new(email: generate_unique_email, password: 'password1', password_confirmation: 'password1')
    assert(modified_user.skip_session_limitable?)
  end

  class SessionLimitableUser < User
    devise :session_limitable
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid
  end

  test 'includes Devise::Models::Compatibility' do
    assert_kind_of(Devise::Models::Compatibility, SessionLimitableUser.new)
  end

  test '#update_unique_session_id!(value) updates valid record' do
    user = User.create! password: 'passWord1', password_confirmation: 'passWord1', email: generate_unique_email
    assert user.persisted?
    assert_nil user.unique_session_id
    user.update_unique_session_id!('unique_value')
    user.reload
    assert_equal('unique_value', user.unique_session_id)
  end

  test '#update_unique_session_id!(value) updates invalid record atomically' do
    email = generate_unique_email
    user = User.create! password: 'passWord1', password_confirmation: 'passWord1', email: email
    assert user.persisted?
    user.email = ''
    assert user.invalid?
    assert_nil user.unique_session_id
    user.update_unique_session_id!('unique_value')
    user.reload
    assert_equal(email, user.email)
    assert_equal('unique_value', user.unique_session_id)
  end

  test '#update_unique_session_id!(value) raises an exception on an unpersisted record' do
    user = User.create
    assert_not user.persisted?
    assert_raises(Devise::Models::Compatibility::NotPersistedError) { user.update_unique_session_id!('unique_value') }
  end
end
