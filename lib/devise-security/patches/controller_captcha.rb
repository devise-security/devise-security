# frozen_string_literal: true

module DeviseSecurity::Patches
  module ControllerCaptcha
    extend ActiveSupport::Concern

    included do
      prepend_before_action :check_captcha, only: [:create]
    end

    private

    def check_captcha
      return if valid_captcha_if_defined?(params[:captcha])

      flash[:alert] = t('devise.invalid_captcha') if is_navigational_format?
      respond_with({}, location: url_for(action: :new))
    end
  end
end
