# frozen_string_literal: true

module DeviseSecurity
  module Patches
    autoload :ControllerCaptcha, 'devise-security/patches/controller_captcha'
    autoload :ControllerSecurityQuestion, 'devise-security/patches/controller_security_question'

    class << self
      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/CyclomaticComplexity
      # rubocop:disable Metrics/PerceivedComplexity
      def apply
        Devise::PasswordsController.include(Patches::ControllerCaptcha) if Devise.captcha_for_recover || Devise.security_question_for_recover
        Devise::UnlocksController.include(Patches::ControllerCaptcha) if Devise.captcha_for_unlock || Devise.security_question_for_unlock
        Devise::ConfirmationsController.include(Patches::ControllerCaptcha) if Devise.captcha_for_confirmation

        Devise::PasswordsController.include(Patches::ControllerSecurityQuestion) if Devise.security_question_for_recover
        Devise::UnlocksController.include(Patches::ControllerSecurityQuestion) if Devise.security_question_for_unlock
        Devise::ConfirmationsController.include(Patches::ControllerSecurityQuestion) if Devise.security_question_for_confirmation

        Devise::RegistrationsController.include(Patches::ControllerCaptcha) if Devise.captcha_for_sign_up
        Devise::SessionsController.include(Patches::ControllerCaptcha) if Devise.captcha_for_sign_in
      end
      # rubocop:enable Metrics/AbcSize
      # rubocop:enable Metrics/CyclomaticComplexity
      # rubocop:enable Metrics/PerceivedComplexity
    end
  end
end
