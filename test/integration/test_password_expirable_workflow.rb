# frozen_string_literal: true

require 'test_helper'

class TestPasswordExpirableWorkflow < ActionDispatch::IntegrationTest
  include IntegrationHelpers

  setup do
    @user = User.create!(password: 'passWord1',
                         password_confirmation: 'passWord1',
                         email: 'bob@microsoft.com',
                         password_changed_at: 4.months.ago) # the default expiration time is 3.months.ago
    @user.confirm

    assert @user.valid?
    assert @user.need_change_password?
  end

  test 'sign in and change expired password' do
    sign_in(@user)
    assert_redirected_to(root_path)
    follow_redirect!
    assert_redirected_to(user_password_expired_path)
    # @note This is not the same controller used by Devise for password changes
    put '/users/password_expired', params: {
      user: {
        current_password: 'passWord1',
        password: 'Password12345!',
        password_confirmation: 'Password12345!'
      }
    }
    assert_redirected_to(root_path)
    @user.reload
    assert_not @user.need_change_password?
  end

  test 'sign in and password is updated before redirect completes' do
    sign_in(@user)
    assert_redirected_to(root_path)

    # simulates an external process updating the password
    @user.update(password_changed_at: Time.zone.now)
    assert_not @user.need_change_password?

    follow_redirect!
    assert_response :success

    # if the password is expired at this point they will be redirected to the
    # password change controller.
    get root_path
    assert_response :success
  end
end
