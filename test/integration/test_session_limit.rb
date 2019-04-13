# frozen_string_literal: true

require 'test_helper'

class TestSessionLimit < ActionDispatch::IntegrationTest
  def unique_traceable_token
    @controller.user_session['unique_traceable_token']
  end

  test 'check if unique_traceable_token is set' do
    sign_in_as_user
    assert_not_nil unique_traceable_token
  end

  test 'sign in with session exceeded should fail' do
    User.any_instance.stubs(:allow_limitable_authentication?).returns(false)
    sign_in_as_user

    assert_not warden.authenticated?(:user)
  end
end
