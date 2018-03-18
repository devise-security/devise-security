require 'test_helper'

class Devise::PasswordExpiredControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = User.create!(
      username: 'hello',
      email: 'hello@path.travel',
      password: 'Password4',
      password_changed_at: 4.months.ago,
      confirmed_at: 5.months.ago
    )
    assert @user.valid?
    sign_in(@user)
  end

  test 'should render show' do
    get :show
    assert_includes @response.body, 'Renew your password'
  end

  test 'should update password' do
    put :update, params: {
      user: {
        current_password: 'Password4',
        password: 'Password5',
        password_confirmation: 'Password5'
      }
    }
    assert_redirected_to root_path
  end
end
