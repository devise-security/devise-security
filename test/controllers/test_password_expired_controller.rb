# frozen_string_literal: true

require 'test_helper'

class Devise::PasswordExpiredControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    @controller.class.respond_to :json, :xml
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

  test 'update password with default format' do
    if Rails.gem_version < Gem::Version.new('5.0')
      put :update,
          {
            user: {
              current_password: 'Password4',
              password: 'Password5',
              password_confirmation: 'Password5'
            }
          }
    else
      put :update,
          params: {
            user: {
              current_password: 'Password4',
              password: 'Password5',
              password_confirmation: 'Password5'
            }
          }
    end
    assert_redirected_to root_path
    assert_equal response.content_type, 'text/html'
  end

  test 'password confirmation does not match' do
    if Rails.gem_version < Gem::Version.new('5.0')
      put :update,
          {
            user: {
              current_password: 'Password4',
              password: 'Password5',
              password_confirmation: 'Password6'
            }
          }
    else
      put :update,
          params: {
            user: {
              current_password: 'Password4',
              password: 'Password5',
              password_confirmation: 'Password6'
            }
          }
    end
    assert_response :success
    assert_template :show
    assert_equal response.content_type, 'text/html'
  end

  test 'update password using JSON format' do
    if Rails.gem_version < Gem::Version.new('5.0')
      # The responders gem that is compatible with Rails 4.2
      # does not return a 204 No Content for common data formats
      # This is the previously existing behavior so it is allowed
      put :update,
          {
            user: {
              current_password: 'Password4',
              password: 'Password5',
              password_confirmation: 'Password5'
            }
          },
          format: :json
      assert_redirected_to root_path
      assert_equal response.content_type, 'text/html'
    else
      put :update,
          format: :json,
          params: {
            user: {
              current_password: 'Password4',
              password: 'Password5',
              password_confirmation: 'Password5'
            }
          }
      assert_response 204
      assert_equal root_url, response.location
      assert_nil response.content_type, 'No Content-Type header should be set for No Content response'
    end
  end

  test 'update password using XML format' do
    if Rails.gem_version < Gem::Version.new('5.0')
      # The responders gem that is compatible with Rails 4.2
      # does not return a 204 No Content for common data formats
      # This is the previously existing behavior so it is allowed
      put :update,
          {
            user: {
              current_password: 'Password4',
              password: 'Password5',
              password_confirmation: 'Password5'
            },
          },
          format: :xml
      assert_redirected_to root_path
      assert_equal response.content_type, 'text/html'
    else
      put :update,
          format: :xml,
          params: {
            user: {
              current_password: 'Password4',
              password: 'Password5',
              password_confirmation: 'Password5'
            }
          }
      assert_response 204
      assert_equal root_url, response.location
      assert_nil response.content_type, 'No Content-Type header should be set for No Content response'
    end
  end
end
