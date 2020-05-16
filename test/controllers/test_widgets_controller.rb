require 'test_helper'

class Devise::WidgetsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @controller = WidgetsController.new
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @user = User.create!(
      username: 'hello',
      email: 'hello@path.travel',
      password: 'Password4',
      password_changed_at: 4.months.ago,
      confirmed_at: 5.months.ago
    )
    assert @user.valid?
    assert @user.need_change_password?

    sign_in(@user)
  end

  test 'should render show' do
    get :show
    assert_includes @response.body, 'success'
  end
end
