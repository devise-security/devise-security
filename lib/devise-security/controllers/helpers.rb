# frozen_string_literal: true

module DeviseSecurity
  module Controllers
    module Helpers
      extend ActiveSupport::Concern

      included do
        before_action :handle_password_change
        before_action :handle_paranoid_verification
      end

      module ClassMethods
        # helper for captcha
        def init_recover_password_captcha
          include RecoverPasswordCaptcha
        end
      end

      module RecoverPasswordCaptcha
        def new
          super
        end
      end

      def valid_captcha_or_security_question?(resource, params)
        valid_captcha_if_defined?(params[:captcha]) ||
          valid_security_question_answer?(resource, params[:security_question_answer])
      end

      def valid_captcha_if_defined?(captcha)
        defined?(verify_recaptcha) && verify_recaptcha ||
          defined?(valid_captcha?) && valid_captcha?(captcha)
      end

      def valid_security_question_answer?(resource, answer)
        resource.security_question_answer.present? &&
          resource.security_question_answer == answer
      end

      # controller instance methods

      private

      # Called as a `before_action` on all actions on any controller that uses
      # this helper. If the user's session is marked as having an expired
      # password we double check in case it has been changed by another process,
      # then redirect to the password change url.
      #
      # @note `Warden::Manager.after_authentication` is run AFTER this method
      #
      # @note Once the warden session has `'password_expired'` set to `false`,
      #    it will **never** be checked again until the user re-logs in.
      def handle_password_change
        return if warden.nil?

        if !devise_controller? &&
           !ignore_password_expire? &&
           !request.format.nil? &&
           request.format.html?
          Devise.mappings.keys.flatten.any? do |scope|
            if signed_in?(scope) && warden.session(scope)['password_expired'] == true
              if send(:"current_#{scope}").try(:need_change_password?)
                store_location_for(scope, request.original_fullpath) if request.get?
                redirect_for_password_change(scope)
              else
                warden.session(scope)['password_expired'] = false
              end
            end
          end
        end
      end

      # lookup if extra (paranoid) code verification is needed
      def handle_paranoid_verification
        return if warden.nil?

        if !devise_controller? && !request.format.nil? && request.format.html?
          Devise.mappings.keys.flatten.any? do |scope|
            if signed_in?(scope) && warden.session(scope)['paranoid_verify']
              store_location_for(scope, request.original_fullpath) if request.get?
              redirect_for_paranoid_verification scope
              return
            end
          end
        end
      end

      # redirect for password update with alert message
      def redirect_for_password_change(scope)
        redirect_to change_password_required_path_for(scope), alert: I18n.t('change_required', scope: 'devise.password_expired')
      end

      def redirect_for_paranoid_verification(scope)
        redirect_to paranoid_verification_code_path_for(scope), alert: I18n.t('code_required', scope: 'devise.paranoid_verify')
      end

      # path for change password
      def change_password_required_path_for(resource_or_scope = nil)
        scope       = Devise::Mapping.find_scope!(resource_or_scope)
        change_path = "#{scope}_password_expired_path"
        send(change_path)
      end

      def paranoid_verification_code_path_for(resource_or_scope = nil)
        scope       = Devise::Mapping.find_scope!(resource_or_scope)
        change_path = "#{scope}_paranoid_verification_code_path"
        send(change_path)
      end

      protected

      # allow to overwrite for some special handlings
      def ignore_password_expire?
        false
      end
    end
  end
end
