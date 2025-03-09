# frozen_string_literal: true

module DeviseSecurity::Patches
  module ControllerCaptcha
    extend ActiveSupport::Concern

    included do
      prepend_before_action :check_captcha, only: [:create]
    end

    private

    # Checks the validity of the captcha provided in the parameters.
    # If the captcha is invalid, sets a flash alert message and redirects to the new action.
    #
    # @see DeviseSecurity::Patches.apply for the controllers that include this method
    # @return [void]
    def check_captcha
      return if valid_captcha_if_defined?(params[:captcha])

      flash[:alert] = t('devise.invalid_captcha') if is_navigational_format?
      respond_with({}, location: url_for(action: :new))
    end
  end
end
