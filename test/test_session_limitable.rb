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
end
