# frozen_string_literal: true

module DeviseSecurity
  # Patches applied to Devise controllers at boot time.
  # Conditionally includes captcha and security-question modules into
  # Devise's built-in controllers based on configuration flags.
  module Patches
    autoload :ControllerCaptcha, 'devise-security/patches/controller_captcha'
    autoload :ControllerSecurityQuestion, 'devise-security/patches/controller_security_question'
    autoload :SecureValidatableControllerInfo, 'devise-security/patches/secure_validatable_controller_info'

    class << self
      # Applies all controller patches based on the current Devise configuration.
      # Called by the {DeviseSecurity::Engine} on each code reload.
      #
      # Includes {ControllerCaptcha} and/or {ControllerSecurityQuestion} into
      # +Devise::PasswordsController+, +Devise::UnlocksController+,
      # +Devise::ConfirmationsController+, +Devise::RegistrationsController+,
      # and +Devise::SessionsController+ when the corresponding
      # +Devise.captcha_for_*+ or +Devise.security_question_for_*+ flags are set.
      #
      # Always prepends {SecureValidatableControllerInfo} into +DeviseController+.
      #
      # @return [void]
      def apply
        Devise::PasswordsController.include(Patches::ControllerCaptcha) if Devise.captcha_for_recover || Devise.security_question_for_recover
        Devise::UnlocksController.include(Patches::ControllerCaptcha) if Devise.captcha_for_unlock || Devise.security_question_for_unlock
        Devise::ConfirmationsController.include(Patches::ControllerCaptcha) if Devise.captcha_for_confirmation

        Devise::PasswordsController.include(Patches::ControllerSecurityQuestion) if Devise.security_question_for_recover
        Devise::UnlocksController.include(Patches::ControllerSecurityQuestion) if Devise.security_question_for_unlock
        Devise::ConfirmationsController.include(Patches::ControllerSecurityQuestion) if Devise.security_question_for_confirmation

        Devise::RegistrationsController.include(Patches::ControllerCaptcha) if Devise.captcha_for_sign_up
        Devise::SessionsController.include(Patches::ControllerCaptcha) if Devise.captcha_for_sign_in

        DeviseController.prepend(Patches::SecureValidatableControllerInfo)
      end
    end
  end
end
