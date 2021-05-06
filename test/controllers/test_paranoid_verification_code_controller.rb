# frozen_string_literal: true

require 'test_helper'

class Devise::ParanoidVerificationCodeControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @request.env['devise.mapping'] = Devise.mappings[:user]

    @user = User.create!(
      username: 'hello',
      email: 'hello@path.travel',
      password: 'Password4',
      confirmed_at: 5.months.ago,
    )

    sign_in(@user)
  end

  test 'redirects to root on show if user not logged in' do
    sign_out(@user)
    get :show
    assert_redirected_to :root
  end

  test "redirects to root on show if user doesn't need paranoid verification" do
    get :show
    assert_redirected_to :root
  end

  test 'renders show on show if user needs paranoid verification' do
    @user.update(paranoid_verification_code: 'cookies')
    get :show
    assert_template :show
  end

  test "redirects to root on update" do
    patch :update, params: { user: { paranoid_verification_code: 'cookies' } }
    assert_redirected_to :root
    assert_equal 'Verification code accepted', flash[:notice]
  end

  test "redirects to custom redirect route on update" do
    Devise.paranoid_verification_code_redirect_location = '/cats'

    patch :update, params: { user: { paranoid_verification_code: 'cookies' } }

    assert_redirected_to '/cats'
    assert_equal 'Verification code accepted', flash[:notice]

    Devise.paranoid_verification_code_redirect_location = nil
  end
end
