# frozen_string_literal: true

class Devise::PasswordExpiredController < DeviseController
  before_action :verify_requested_format!
  skip_before_action :handle_password_change
  before_action :skip_password_change, only: [:show, :update]
  prepend_before_action :authenticate_scope!, only: [:show, :update]

  def show
    respond_with(resource)
  end

  # Update the password stored on the `resource`.
  # @note if a common data format like :json or :xml are requested
  #   this will respond with a 204 No Content and set the Location header.
  #   Useful for dealing with APIs when JS clients would otherwise automatically
  #   follow the redirect, which can be problematic.
  # @see https://stackoverflow.com/questions/228225/prevent-redirection-of-xmlhttprequest
  # @see https://github.com/axios/axios/issues/932#issuecomment-307390761
  # @see https://github.com/devise-security/devise-security/pull/111
  def update
    resource.extend(Devise::Models::DatabaseAuthenticatablePatch)
    if resource.update_with_password(resource_params)
      warden.session(scope)['password_expired'] = false
      set_flash_message :notice, :updated
      bypass_sign_in resource, scope: scope
      respond_with({}, location: stored_location_for(scope) || :root)
    else
      clean_up_passwords(resource)
      respond_with(resource, action: :show)
    end
  end

  private

  def skip_password_change
    return if !resource.nil? && resource.need_change_password?
    redirect_to :root
  end

  def resource_params
    permitted_params = [:current_password, :password, :password_confirmation]

    params.require(resource_name).permit(*permitted_params)
  end

  def scope
    resource_name.to_sym
  end

  def authenticate_scope!
    send(:"authenticate_#{resource_name}!")
    self.resource = send("current_#{resource_name}")
  end
end
