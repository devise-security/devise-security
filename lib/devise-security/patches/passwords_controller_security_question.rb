# frozen_string_literal: true

module DeviseSecurity::Patches
  module PasswordsControllerSecurityQuestion
    extend ActiveSupport::Concern
    included do
      define_method :create do
        # only find via email, not login
        resource = resource_class.find_or_initialize_with_error_by(:email, params[resource_name][:email], :not_found)

        if valid_captcha_or_security_question?(resource, params)
          self.resource = resource_class.send_reset_password_instructions(params[resource_name])
          if successfully_sent?(resource)
            respond_with({}, location: new_session_path(resource_name))
          else
            respond_with(resource)
          end
        else
          flash[:alert] = t('devise.invalid_security_question') if is_navigational_format?
          respond_with({}, location: new_password_path(resource_name))
        end
      end
    end
  end
end
