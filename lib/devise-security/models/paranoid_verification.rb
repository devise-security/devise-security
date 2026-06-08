# frozen_string_literal: true

require 'devise-security/hooks/paranoid_verification'

module Devise
  module Models
    # ParanoidVerification adds a secondary verification step after login.
    # The user must enter a verification code before accessing the application.
    # After +paranoid_code_regenerate_after_attempt+ failed attempts, the code
    # is regenerated automatically. The code generator is configurable via
    # +verification_code_generator+ (a Proc/Lambda).
    #
    # == Database fields
    #
    # - +paranoid_verification_code+ - the current verification code (+nil+ when verified)
    # - +paranoid_verification_attempt+ - number of failed attempts for the current code
    # - +paranoid_verified_at+ - timestamp of last successful verification
    #
    # @see https://github.com/devise-security/devise-security
    module ParanoidVerification
      extend ActiveSupport::Concern

      # @param _klass [Class]
      # @return [Array<Symbol>] required database fields
      def self.required_fields(_klass)
        %i[paranoid_verification_code paranoid_verification_attempt paranoid_verified_at]
      end

      # Whether the user still needs to complete paranoid verification.
      # Returns +true+ when a verification code is present (i.e., not yet verified).
      #
      # @return [Boolean]
      def need_paranoid_verification?
        !!paranoid_verification_code
      end

      # Attempt to verify the given code against the stored verification code.
      # On success, clears the code and records +paranoid_verified_at+.
      # On failure, increments the attempt counter. When the attempt count reaches
      # +paranoid_code_regenerate_after_attempt+, a new code is generated and the
      # counter resets.
      #
      # @param code [String] the verification code entered by the user
      # @return [Boolean] +true+ if the code matched, +false+ otherwise
      def verify_code(code)
        attempt = paranoid_verification_attempt

        if (attempt += 1) >= paranoid_code_regenerate_after_attempt
          generate_paranoid_code
          false
        elsif code == paranoid_verification_code
          attempt = 0
          update_without_password paranoid_verification_code: nil,
                                  paranoid_verified_at: Time.zone.now,
                                  paranoid_verification_attempt: attempt
          true
        else
          update_without_password paranoid_verification_attempt: attempt
          false
        end
      end

      # Number of verification attempts remaining before the code is regenerated.
      #
      # @return [Integer]
      def paranoid_attempts_remaining
        paranoid_code_regenerate_after_attempt - paranoid_verification_attempt
      end

      # Generate a new verification code and reset the attempt counter.
      # Uses +verification_code_generator+ to produce the code.
      #
      # @return [Boolean] result of the +update_without_password+ call
      def generate_paranoid_code
        update_without_password paranoid_verification_code: verification_code_generator.call,
                                paranoid_verification_attempt: 0
      end

      # Number of failed attempts before regenerating the verification code.
      # Override in your model for per-record dynamic behavior.
      #
      # @return [Integer]
      delegate :paranoid_code_regenerate_after_attempt, to: :class

      # Lambda/proc that generates verification codes.
      # Override in your model for per-record dynamic behavior.
      #
      # @return [Proc]
      delegate :verification_code_generator, to: :class

      class_methods do
        ::Devise::Models.config(
          self,
          :paranoid_code_regenerate_after_attempt,
          :verification_code_generator
        )
      end
    end
  end
end
