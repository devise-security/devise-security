# frozen_string_literal: true

require_relative 'compatibility'
require_relative "#{DEVISE_ORM}/banned_password"

module Devise
  module Models
    module PasswordBannable
      extend ActiveSupport::Concern
      include Devise::Models::Compatibility

      included do
        validate :password_not_banned, if: -> { password.present? }
      end

      def password_not_banned
        return unless BannedPassword.where(password: password).exists?

        errors.add(:password, :banned_password)
      end
    end
  end
end