# frozen_string_literal: true

require_relative 'compatibility'

module Devise
  module Models
    module PasswordBannable
      extend ActiveSupport::Concern
      include Devise::Models::Compatibility

      included do
        validate :password_not_banned, if: :password_present?
      end

      delegate :present?, to: :password, prefix: true

      def password_not_banned
        return unless BannedPassword.where(password: password).exists?

        errors.add(:password, 'sucks to be you')
      end
    end
  end
end