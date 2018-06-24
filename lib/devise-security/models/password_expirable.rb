# frozen_string_literal: true

require 'devise-security/hooks/password_expirable'

module Devise
  module Models
    # PasswordExpirable makes passwords expire after a configurable amount of
    # time, or on demand
    module PasswordExpirable
      extend ActiveSupport::Concern

      included do
        scope :with_password_change_requested, -> { where(password_changed_at: nil) }
        scope :without_password_change_requested, -> { where.not(password_changed_at: nil) }
        scope :with_expired_password, -> { where('password_changed_at is NULL OR password_changed_at < ?', expire_password_after.seconds.ago) }
        scope :without_expired_password, -> { without_password_change_requested.where('password_changed_at >= ?', expire_password_after.seconds.ago) }
        before_save :update_password_changed
      end

      # Is a password change required?
      # @return [Boolean]
      # @return [true] if +password_changed_at+ has not been set or if it is old
      #   enough based on +expire_password_after+ configuration.
      def need_change_password?
        password_change_requested? || password_too_old?
      end

      # Adjust the +password_changed_at+ field so that it will require a
      # password update and save the record (without validations)
      # @return [Boolean]
      def need_change_password!
        return unless password_expiration_enabled?
        need_change_password
        save(validate: false)
      end
      alias expire_password! need_change_password!
      alias request_password_change! need_change_password!

      # Clear the +password_changed_at+ field so that it will require a
      # password update.
      # @return [void]
      def need_change_password
        return unless password_expiration_enabled?
        self.password_changed_at = nil
      end
      alias expire_password need_change_password
      alias request_password_change need_change_password

      # Set this value to a number of seconds to have passwords expire after a time
      # Set to +true+ if you want to be able to manually expire passwords on demand
      # without a time limit.
      # @return [Numeric, Boolean]
      def expire_password_after
        self.class.expire_password_after
      end

      # When +password_changed_at+ is set to null in the database
      # the user is required to change their password.  This only happens
      # on demand or when the column is first added to the table.
      # @return [Boolean]
      def password_change_requested?
        return false unless password_expiration_enabled?
        return false if new_record?
        password_changed_at.nil?
      end

      # Is this password older than the configured expiration timeout
      # @return [Boolean]
      def password_too_old?
        return false if new_record?
        return false unless password_expiration_enabled?
        return false if expire_password_on_demand?
        password_changed_at < expire_password_after.seconds.ago
      end
      alias password_expired? password_too_old?

      private

      # is password changed then update password_changed_at
      # @note called as a +before_save+ hook
      def update_password_changed
        return unless (new_record? || encrypted_password_changed?) && !password_changed_at_changed?
        self.password_changed_at = Time.zone.now
      end

      # Enabled if configuration +expire_password_after+ is set to an {Integer}, {Float}, or {true}
      def password_expiration_enabled?
        expire_password_after.present? &&
        expire_password_after.is_a?(1.class) ||
          expire_password_after.is_a?(Float) ||
          expire_password_on_demand?
      end

      def expire_password_on_demand?
        expire_password_after.present? && expire_password_after == true
      end

      module ClassMethods
        ::Devise::Models.config(self, :expire_password_after)
      end
    end
  end
end
