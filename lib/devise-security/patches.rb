# frozen_string_literal: true

module DeviseSecurity
  module Patches
    autoload :ControllerCaptcha, 'devise-security/patches/controller_captcha'
    autoload :ControllerSecurityQuestion, 'devise-security/patches/controller_security_question'
    autoload :SetMinimumPasswordInformation, 'devise-security/patches/set_minimum_password_information'

    class << self
      def apply
        Devise::PasswordsController.send(:include, Patches::ControllerCaptcha) if Devise.captcha_for_recover || Devise.security_question_for_recover
        Devise::UnlocksController.send(:include, Patches::ControllerCaptcha) if Devise.captcha_for_unlock || Devise.security_question_for_unlock
        Devise::ConfirmationsController.send(:include, Patches::ControllerCaptcha) if Devise.captcha_for_confirmation

        Devise::PasswordsController.send(:include, Patches::ControllerSecurityQuestion) if Devise.security_question_for_recover
        Devise::UnlocksController.send(:include, Patches::ControllerSecurityQuestion) if Devise.security_question_for_unlock
        Devise::ConfirmationsController.send(:include, Patches::ControllerSecurityQuestion) if Devise.security_question_for_confirmation

        Devise::RegistrationsController.send(:include, Patches::ControllerCaptcha) if Devise.captcha_for_sign_up
        Devise::SessionsController.send(:include, Patches::ControllerCaptcha) if Devise.captcha_for_sign_in

        # TODO conditional include
        DeviseController.send(:include, Patches::SetMinimumPasswordInformation)
      end
    end
  end
end
