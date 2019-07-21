# frozen_string_literal: true

require 'test_helper'

class TestSessionLimitable < ActiveSupport::TestCase
  class ModifiedUser < User
    def skip_session_limitable?
      true
    end
  end

  test 'check is not skipped by default' do
    user = User.create email: 'bob@microsoft.com', password: 'password1', password_confirmation: 'password1'
    assert_equal(false, user.skip_session_limitable?)
  end

  test 'default check can be overridden by record instance' do
    modified_user = ModifiedUser.create email: 'bob2@microsoft.com', password: 'password1', password_confirmation: 'password1'
    assert_equal(true, modified_user.skip_session_limitable?)
  end
    
  class SessionLimitableUser < User
    devise :session_limitable
    include ::Mongoid::Mappings if DEVISE_ORM == :mongoid
  end

  test 'includes Devise::Models::Compatibility' do
    assert_kind_of(Devise::Models::Compatibility, SessionLimitableUser.new)
  end

  test '#update_unique_session_id!(value) updates valid record' do
    user = User.create! password: 'passWord1', password_confirmation: 'passWord1', email: 'bob@microsoft.com'
    assert user.persisted?
    assert_nil user.unique_session_id
    user.update_unique_session_id!('unique_value')
    user.reload
    assert_equal user.unique_session_id, 'unique_value'
  end

  test '#update_unique_session_id!(value) updates invalid record atomically' do
    user = User.create! password: 'passWord1', password_confirmation: 'passWord1', email: 'bob@microsoft.com'
    assert user.persisted?
    user.email = ''
    assert user.invalid?
    assert_nil user.unique_session_id
    user.update_unique_session_id!('unique_value')
    user.reload
    assert_equal user.email, 'bob@microsoft.com'
    assert_equal user.unique_session_id, 'unique_value'
  end

  test '#update_unique_session_id!(value) raises an exception on an unpersisted record' do
    user = User.create
    assert !user.persisted?
    assert_raises(Devise::Models::Compatibility::NotPersistedError) { user.update_unique_session_id!('unique_value') }
  end
end
