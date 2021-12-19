# frozen_string_literal: true

module Devise
  module Models
    module DatabaseAuthenticatablePatch
      def update_with_password(params, *options)
        current_password = params.delete(:current_password)
        valid_password = valid_password?(current_password)

        new_password = params[:password]
        new_password_confirmation = params[:password_confirmation]

        result = if valid_password && new_password.present? && new_password_confirmation.present?
          update(params, *options)
        else
          self.assign_attributes(params, *options)

          if current_password.blank?
            self.errors.add(:current_password, :blank)
          elsif !valid_password
            self.errors.add(:current_password, :invalid)
          end

          self.errors.add(:password, :blank) if new_password.blank?

          if new_password_confirmation.blank?
            self.errors.add(:password_confirmation, :blank)
          end

          false
        end

        clean_up_passwords
        result
      end
    end
  end
end
