# frozen_string_literal: true

require 'test_helper'

class TestParanoidVerificationCodeWorkflow < ActionDispatch::IntegrationTest
  include IntegrationHelpers

  setup do
    @user = User.create!(
      password: 'passWord1',
      password_confirmation: 'passWord1',
      email: 'bob@microsoft.com',
      paranoid_verification_code: 'cookies'
    ) # the default verification code is nil
    @user.confirm

    assert @user.valid?
    assert @user.need_paranoid_verification?
  end

  test 'sign in and check paranoid verification code' do
    sign_in(@user)
    assert_redirected_to(root_path)
    follow_redirect!
    assert_redirected_to(user_paranoid_verification_code_path)
    # @note This is not the same controller used by Devise for password changes
    patch '/users/verification_code', params: {
      user: {
        paranoid_verification_code: 'cookies'
      }
    }
    assert_redirected_to(root_path)
    @user.reload
    assert_not @user.need_paranoid_verification?
  end

  test 'sign in and paranoid verification code is checked before redirect completes' do
    sign_in(@user)
    assert_redirected_to(root_path)

    # simulates an external process verifying the paranoid verification code
    @user.update(paranoid_verification_code: nil)
    assert_not @user.need_paranoid_verification?

    follow_redirect!
    assert_response :success

    # if the paranoid verification code is not empty/nil at this point they will be redirected to the
    # paranoid verification code change controller.
    get root_path
    assert_response :success
  end
end
