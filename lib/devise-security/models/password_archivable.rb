# frozen_string_literal: true

require_relative 'compatibility'

module Devise
  module Models
    # PasswordArchivable, this depends on the database_authenticatable module from devise
    module PasswordArchivable
      extend ActiveSupport::Concern
      include Devise::Models::Compatibility

      included do
        devise :database_authenticatable
        has_many :old_passwords, as: :password_archivable, dependent: :destroy
        before_update :archive_password, if: :will_save_change_to_encrypted_password?
        validate :validate_password_archive, if: :password_present?
      end

      delegate :present?, to: :password, prefix: true

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

      # validate is the password used in the past
      # @return [true] if current password was used previously
      # @return [false] if disabled or not previously used
      def password_archive_included?
        return false unless max_old_passwords > 0
        old_passwords_including_cur_change = old_passwords.order(:id).reverse_order.limit(max_old_passwords).pluck(:encrypted_password)
        old_passwords_including_cur_change << encrypted_password_was # include most recent change in list, but don't save it yet!
        old_passwords_including_cur_change.any? do |old_password|
          self.class.new(encrypted_password: old_password).valid_password?(password)
        end
      end

      def deny_old_passwords
        self.class.deny_old_passwords
      end

      def deny_old_passwords=(count)
        self.class.deny_old_passwords = count
      end

      def archive_count
        self.class.password_archiving_count
      end

      private

      # archive the last password before save and delete all to old passwords from archive
      def archive_password
        if max_old_passwords > 0
          old_passwords.create!(encrypted_password: encrypted_password_was) if encrypted_password_was.present?
          old_passwords.order(:id).reverse_order.offset(max_old_passwords).destroy_all
        else
          old_passwords.destroy_all
        end
      end

      module ClassMethods
        ::Devise::Models.config(self, :password_archiving_count, :deny_old_passwords)
      end
    end
  end
end
