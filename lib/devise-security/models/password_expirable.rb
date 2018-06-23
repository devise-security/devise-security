# frozen_string_literal: true

require 'devise-security/hooks/password_expirable'

module Devise
  module Models
    # PasswordExpirable makes passwords expire after a configurable amount of
    # time, or on demand
    module PasswordExpirable
      extend ActiveSupport::Concern

      included do
        before_save :update_password_changed
      end

      # Is a password change required?
      # @return [Boolean]
      # @return [true] if +password_changed_at+ has not been set or if it is old
      #   enough based on +expire_password_after+ configuration.
      def need_change_password?
        if enabled?
          if expire_on_demand?
            # Only expire when password_changed_at is nil
            password_changed_at.nil?
          else
            # Expire when password_changed_at is nil or when the last time the
            # password was changed is sufficiently old
            password_changed_at.nil? || password_changed_at < expire_password_after.seconds.ago
          end
        else
          false
        end
      end

      # Adjust the +password_changed_at+ field so that it will require a
      # password update and save the record (without validations)
      # @return [Boolean]
      def need_change_password!
        return unless enabled?
        need_change_password
        save(validate: false)
      end

      # Clear the +password_changed_at+ field so that it will require a
      # password update.
      # @return [void]
      def need_change_password
        return unless enabled?
        self.password_changed_at = nil
      end

      # Set this value to a number of seconds to have passwords expire after a time
      # Set to +true+ if you want to be able to manually expire passwords on demand
      # without a time limit.
      # @return [Numeric, true]
      def expire_password_after
        self.class.expire_password_after
      end

      private

      # is password changed then update password_changed_at
      # @note called as a +before_save+ hook
      def update_password_changed
        return unless (new_record? || encrypted_password_changed?) && !password_changed_at_changed?
        self.password_changed_at = Time.zone.now
      end

      # Enabled if configuration +expire_password_after+ is set to an {Integer}, {Float}, or {true}
      def enabled?
        return @enabled if defined?(@enabled)
        @enabled = expire_password_after.is_a?(1.class) ||
                   expire_password_after.is_a?(Float) ||
                   expire_password_after == true
      end

      def expire_on_demand?
        expire_password_after == true
      end

      module ClassMethods
        ::Devise::Models.config(self, :expire_password_after)
      end
    end
  end
end
