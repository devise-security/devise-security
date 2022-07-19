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
                   assign_attributes(params, *options)

                   if current_password.blank?
                     errors.add(:current_password, :blank)
                   elsif !valid_password
                     errors.add(:current_password, :invalid)
                   end

                   errors.add(:password, :blank) if new_password.blank?

                   errors.add(:password_confirmation, :blank) if new_password_confirmation.blank?

                   false
                 end

        clean_up_passwords
        result
      end
    end
  end
end
