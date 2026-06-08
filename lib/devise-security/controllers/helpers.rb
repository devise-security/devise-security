# frozen_string_literal: true

module DeviseSecurity
  module Controllers
    # Helpers mixed into all controllers via the {DeviseSecurity::Engine}.
    # Provides before-action hooks for expired-password and paranoid-verification
    # redirects, plus captcha/security-question validation helpers.
    module Helpers
      extend ActiveSupport::Concern

      included do
        before_action :handle_password_change
        before_action :handle_paranoid_verification
      end

      module ClassMethods
        # Includes the {RecoverPasswordCaptcha} module into the controller,
        # enabling captcha support on the password recovery +new+ action.
        #
        # @return [void]
        def init_recover_password_captcha
          include RecoverPasswordCaptcha
        end
      end

      # Mixin that overrides the +new+ action to allow captcha rendering
      # on the password recovery form.
      module RecoverPasswordCaptcha
      end

      # Checks whether the request passes either a captcha or a security
      # question answer. Used by patched Devise controllers for recover,
      # unlock, and confirmation flows.
      #
      # @param resource [ActiveRecord::Base] the Devise resource (e.g. User)
      # @param params [Hash] request parameters containing +:captcha+ and/or
      #   +:security_question_answer+
      # @return [Boolean] +true+ if either validation passes
      # @see #valid_captcha_if_defined?
      # @see #valid_security_question_answer?
      def valid_captcha_or_security_question?(resource, params)
        valid_captcha_if_defined?(params[:captcha]) ||
          valid_security_question_answer?(resource, params[:security_question_answer])
      end

      # Validates a captcha value if a captcha library (reCAPTCHA or simple_captcha)
      # is available. Returns +false+ when no captcha library is defined.
      #
      # @param captcha [String, nil] the captcha value from the form
      # @return [Boolean] +true+ if a captcha library is present and validation passes
      def valid_captcha_if_defined?(captcha)
        (defined?(verify_recaptcha) && verify_recaptcha) ||
          (defined?(valid_captcha?) && valid_captcha?(captcha))
      end

      # Validates a security question answer against the resource's stored answer.
      #
      # @param resource [ActiveRecord::Base] the Devise resource with
      #   +security_question_answer+ attribute
      # @param answer [String, nil] the user-supplied answer
      # @return [Boolean] +true+ if the answer matches
      # @see Devise::Models::SecurityQuestionable
      def valid_security_question_answer?(resource, answer)
        resource.security_question_answer.present? &&
          resource.security_question_answer == answer
      end

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

        if !devise_controller? &&
           !ignore_paranoid_verification_code? &&
           !request.format.nil? &&
           request.format.html?
          Devise.mappings.keys.flatten.any? do |scope|
            if signed_in?(scope) && warden.session(scope)['paranoid_verify'] == true
              if send(:"current_#{scope}").try(:need_paranoid_verification?)
                store_location_for(scope, request.original_fullpath) if request.get?
                redirect_for_paranoid_verification(scope)
              else
                warden.session(scope)['paranoid_verify'] = false
              end
            end
          end
        end
      end

      # Redirects the user to the password-change form with a localized alert.
      #
      # @param scope [Symbol] the Devise scope (e.g. +:user+)
      # @return [void]
      def redirect_for_password_change(scope)
        redirect_to change_password_required_path_for(scope), alert: I18n.t('change_required', scope: 'devise.password_expired')
      end

      # Redirects the user to the paranoid verification code form with a
      # localized alert.
      #
      # @param scope [Symbol] the Devise scope (e.g. +:user+)
      # @return [void]
      def redirect_for_paranoid_verification(scope)
        redirect_to paranoid_verification_code_path_for(scope), alert: I18n.t('code_required', scope: 'devise.paranoid_verify')
      end

      # Returns the route path for the password-expired form.
      # Resolves the correct router context when engines are mounted.
      #
      # @param resource_or_scope [Symbol, ActiveRecord::Base, nil] a Devise scope
      #   or resource instance
      # @return [String] URL path (e.g. +"/users/password_expired"+)
      def change_password_required_path_for(resource_or_scope = nil)
        scope       = Devise::Mapping.find_scope!(resource_or_scope)
        router_name = Devise.mappings[scope].router_name
        context     = router_name ? send(router_name) : _devise_route_context
        context.send("#{scope}_password_expired_path")
      end

      # Returns the route path for the paranoid verification code form.
      # Resolves the correct router context when engines are mounted.
      #
      # @param resource_or_scope [Symbol, ActiveRecord::Base, nil] a Devise scope
      #   or resource instance
      # @return [String] URL path (e.g. +"/users/paranoid_verification_code"+)
      def paranoid_verification_code_path_for(resource_or_scope = nil)
        scope       = Devise::Mapping.find_scope!(resource_or_scope)
        router_name = Devise.mappings[scope].router_name
        context     = router_name ? send(router_name) : _devise_route_context
        context.send("#{scope}_paranoid_verification_code_path")
      end

      protected

      # Override in your controller to skip the expired-password redirect
      # for specific actions or conditions.
      #
      # @return [Boolean] +true+ to skip the password-expiry check
      def ignore_password_expire?
        false
      end

      # Override in your controller to skip the paranoid-verification redirect
      # for specific actions or conditions.
      #
      # @return [Boolean] +true+ to skip the verification-code check
      def ignore_paranoid_verification_code?
        false
      end
    end
  end
end
