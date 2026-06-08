# frozen_string_literal: true

require_relative 'compatibility'
require_relative "#{DEVISE_ORM}/old_password"

module Devise
  module Models
    # PasswordArchivable prevents password reuse by archiving old passwords.
    # Each password change stores the previous encrypted password in an
    # +OldPassword+ record. On validation, the new password is checked against
    # the most recent archived passwords.
    #
    # == Configuration
    # * +deny_old_passwords+ - +Integer+ count of old passwords to deny,
    #   +true+ to deny all archived, or +false+ to disable (default: +false+)
    # * +deny_old_passwords_period+ - +ActiveSupport::Duration+ time window
    #   for denying reuse (e.g. +3.months+). Takes precedence over count.
    #   +nil+ (default) disables time-based checking.
    # * +password_archiving_count+ - max number of old passwords to store
    #
    # @see OldPassword the model storing archived password hashes
    # @see Devise::Models::DatabaseAuthenticatable required base module
    module PasswordArchivable
      extend ActiveSupport::Concern
      include Devise::Models::Compatibility
      include Devise::Models::DatabaseAuthenticatable

      included do
        has_many :old_passwords, class_name: 'OldPassword', as: :password_archivable, dependent: :destroy
        before_update :archive_password, if: :will_save_change_to_encrypted_password?
        validate :validate_password_archive, if: :password_present?
      end

      delegate :present?, to: :password, prefix: true

      # @param _klass [Class] the model class including this module
      # @return [Array<Symbol>] required database columns (none for this module)
      def self.required_fields(_klass)
        []
      end

      # Add a validation error if the new password matches a previously used one.
      # @return [void]
      def validate_password_archive
        errors.add(:password, :taken_in_past) if will_save_change_to_encrypted_password? && password_archive_included?
      end

      # @return [Integer] max number of old passwords to store and check
      def max_old_passwords
        case deny_old_passwords
        when true
          [1, archive_count].max
        when false
          0
        else
          deny_old_passwords.to_i
        end
      end

      # Check if the new password matches any previously used password.
      # When +deny_old_passwords_period+ is set, checks passwords archived
      # within that time window (takes precedence over count-based checking).
      # Otherwise falls back to count-based checking via +max_old_passwords+.
      #
      # Always includes the current (about-to-be-replaced) encrypted password.
      #
      # @return [true] if the new password was used previously
      # @return [false] if reuse checking is disabled or no match found
      def password_archive_included?
        period = deny_old_passwords_period

        if period
          # Time-based: check passwords created within the period
          old_passwords_to_check = old_passwords.where(created_at: period.ago..).pluck(:encrypted_password)
        else
          # Count-based: existing logic
          return false unless max_old_passwords.positive?

          old_passwords_to_check = old_passwords.reorder(created_at: :desc).limit(max_old_passwords).pluck(:encrypted_password)
        end

        old_passwords_to_check << encrypted_password_was # include most recent change in list, but don't save it yet!
        old_passwords_to_check.any? do |old_password|
          # NOTE: we deliberately do not do mass assignment here so that users that
          #   rely on `protected_attributes_continued` gem can still use this extension.
          #   See issue #68
          self.class.new.tap { |object| object.encrypted_password = old_password }.valid_password?(password)
        end
      end

      # Maximum number of old passwords to deny reuse of.
      # Override in your model for per-record dynamic behavior.
      # Supports +Proc+ values — resolved via +instance_exec+ so the Proc
      # has access to the model instance (e.g., for role-based logic).
      #
      # @return [Integer, Boolean] count, +true+ (deny all), or +false+ (allow all)
      def deny_old_passwords
        value = self.class.deny_old_passwords
        value.is_a?(Proc) ? instance_exec(&value) : value
      end

      # Set the deny_old_passwords config on the class.
      #
      # @param count [Integer, Boolean]
      delegate :deny_old_passwords=, to: :class

      # Time period for denying old password reuse.
      # Override in your model for per-record dynamic behavior.
      # Supports +Proc+ values — resolved via +instance_exec+ so the Proc
      # has access to the model instance (e.g., for role-based logic).
      #
      # @return [ActiveSupport::Duration, nil] time period, or +nil+ to use count-based
      def deny_old_passwords_period
        value = self.class.deny_old_passwords_period
        value.is_a?(Proc) ? instance_exec(&value) : value
      end

      # Number of old passwords to archive.
      # Override in your model for per-record dynamic behavior.
      # Supports +Proc+ values — resolved via +instance_exec+.
      #
      # @return [Integer]
      def archive_count
        value = self.class.password_archiving_count
        value.is_a?(Proc) ? instance_exec(&value) : value
      end

      private

      # Archive the current encrypted password before save and prune excess entries.
      # When archiving is disabled (+max_old_passwords+ is 0 and no period set),
      # destroys all archives. When +deny_old_passwords_period+ is set, archives
      # are always created (even if count-based checking is disabled).
      #
      # @note Checks for an existing archive entry to avoid duplicates caused by
      #   Mongoid re-triggering callbacks when adding an old password.
      # @return [void]
      def archive_password
        if max_old_passwords.positive? || deny_old_passwords_period
          return true if old_passwords.exists?(encrypted_password: encrypted_password_was)

          old_passwords.create!(encrypted_password: encrypted_password_was) if encrypted_password_was.present?

          # When period-based checking is active, prune by archive_count (storage limit)
          # rather than max_old_passwords (denial count) to retain enough history.
          prune_limit = deny_old_passwords_period ? [archive_count, max_old_passwords].max : max_old_passwords
          old_passwords.reorder(created_at: :desc).offset(prune_limit).destroy_all if prune_limit.positive?
        else
          old_passwords.destroy_all
        end
      end

      class_methods do
        ::Devise::Models.config(self, :password_archiving_count, :deny_old_passwords, :deny_old_passwords_period)
      end
    end
  end
end
