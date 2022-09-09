# frozen_string_literal: true

require 'test_helper'

class Devise::PasswordExpiredControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @controller.class.respond_to :json, :xml
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

  test 'redirects on show if user not logged in' do
    sign_out(@user)
    get :show
    assert_redirected_to :root
  end

  test 'redirects on show if user does not need password change' do
    @user.update(password_changed_at: Time.zone.now)
    get :show
    assert_redirected_to :root
  end

  test 'should render show' do
    get :show
    assert_includes @response.body, 'Renew your password'
  end

  test 'redirects on update if user not logged in' do
    sign_out(@user)
    put :update
    assert_redirected_to :root
  end

  test 'redirects on update if user does not need password change' do
    @user.update(password_changed_at: Time.zone.now)
    put :update
    assert_redirected_to :root
  end

  test 'update password with default format' do
    put(
      :update,
      params: {
        user: {
          current_password: 'Password4',
          password: 'Password5',
          password_confirmation: 'Password5'
        }
      }
    )
    assert_redirected_to root_path
    assert_equal('text/html', response.media_type)
  end

  test 'password confirmation does not match' do
    put(
      :update,
      params: {
        user: {
          current_password: 'Password4',
          password: 'Password5',
          password_confirmation: 'Password6'
        }
      }
    )

    assert_response :success
    assert_template :show
    assert_equal('text/html', response.media_type)
    assert_includes(
      response.body,
      'Password confirmation doesn&#39;t match Password'
    )
  end

  test 'update password using JSON format' do
    put(
      :update,
      format: :json,
      params: {
        user: {
          current_password: 'Password4',
          password: 'Password5',
          password_confirmation: 'Password5'
        }
      }
    )

    assert_response 204
    assert_equal root_url, response.location
    assert_nil response.media_type, 'No Content-Type header should be set for No Content response'
  end

  test 'update password using XML format' do
    put(
      :update,
      format: :xml,
      params: {
        user: {
          current_password: 'Password4',
          password: 'Password5',
          password_confirmation: 'Password5'
        }
      }
    )
    assert_response 204
    assert_equal root_url, response.location
    assert_nil response.media_type, 'No Content-Type header should be set for No Content response'
  end
end

class PasswordExpiredCustomRedirectTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers
  tests Overrides::PasswordExpiredController

  setup do
    @controller.class.respond_to :json, :xml
    @request.env['devise.mapping'] = Devise.mappings[:password_expired_user]
    @user = PasswordExpiredUser.create!(
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

  test 'update password with custom redirect route' do
    put(
      :update,
      params: {
        password_expired_user: {
          current_password: 'Password4',
          password: 'Password5',
          password_confirmation: 'Password5'
        }
      }
    )

    assert_redirected_to '/cookies'
  end

  test 'yield resource to block on update' do
    put(:update, params: { password_expired_user: { current_password: '123' } })
    assert @controller.update_block_called?, 'Update failed to yield resource to provided block'
  end
end
