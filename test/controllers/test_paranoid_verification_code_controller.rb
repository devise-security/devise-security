# frozen_string_literal: true

require 'test_helper'

class Devise::ParanoidVerificationCodeControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @controller.class.respond_to :json, :xml
    @request.env['devise.mapping'] = Devise.mappings[:user]
    @user = User.create!(
      username: 'hello',
      email: 'hello@path.travel',
      password: 'Password4',
      confirmed_at: 5.months.ago,
      paranoid_verification_code: 'cookies'
    )
    assert @user.valid?
    assert @user.need_paranoid_verification?

    sign_in(@user)
  end

  test 'redirects to root on show if user not logged in' do
    sign_out(@user)
    get :show
    assert_redirected_to :root
  end

  test "redirects to root on show if user doesn't need paranoid verification" do
    @user.update(paranoid_verification_code: nil)
    get :show
    assert_redirected_to :root
  end

  test 'renders show on show if user needs paranoid verification' do
    @user.update(paranoid_verification_code: 'cookies')
    get :show
    assert_template :show
  end

  test 'redirects on update if user not logged in' do
    sign_out(@user)
    patch :update
    assert_redirected_to :root
  end

  test 'redirects on update if user does not need paranoid verification' do
    @user.update(paranoid_verification_code: nil)
    patch :update
    assert_redirected_to :root
  end

  test 'update paranoid_verification_code with default format' do
    patch(
      :update,
      params: {
        user: {
          paranoid_verification_code: 'cookies'
        }
      }
    )
    assert_redirected_to root_path
    assert_equal 'Verification code accepted', flash[:notice]
    assert_equal('text/html', response.media_type)
  end

  test 'update paranoid_verification_code using JSON format' do
    patch(
      :update,
      format: :json,
      params: {
        user: {
          paranoid_verification_code: 'cookies'
        }
      }
    )

    assert_response 204
    assert_equal root_url, response.location
    assert_nil response.media_type, 'No Content-Type header should be set for No Content response'
  end

  test 'update paranoid_verification_code using XML format' do
    patch(
      :update,
      format: :xml,
      params: {
        user: {
          paranoid_verification_code: 'cookies'
        }
      }
    )
    assert_response 204
    assert_equal root_url, response.location
    assert_nil response.media_type, 'No Content-Type header should be set for No Content response'
  end
end

class ParanoidVerificationCodeCustomRedirectTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  tests Overrides::ParanoidVerificationCodeController

  setup do
    @controller.class.respond_to :json, :xml
    @request.env['devise.mapping'] = Devise.mappings[:paranoid_verification_user]
    @user = ParanoidVerificationUser.create!(
      username: 'hello',
      email: 'hello@path.travel',
      password: 'Password4',
      confirmed_at: 5.months.ago,
      paranoid_verification_code: 'cookies'
    )
    assert @user.valid?
    assert @user.need_paranoid_verification?

    sign_in(@user)
  end

  test 'redirects to custom redirect route on update' do
    patch(
      :update,
      params: {
        paranoid_verification_user: {
          paranoid_verification_code: 'cookies'
        }
      }
    )

    assert_redirected_to '/cats'
    assert_equal 'Verification code accepted', flash[:notice]
  end
end
