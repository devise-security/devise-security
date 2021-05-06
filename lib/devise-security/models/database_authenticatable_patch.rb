# frozen_string_literal: true

module Devise
  module Models
    module DatabaseAuthenticatablePatch
      def update_with_password(params, *options)
        current_password = params.delete(:current_password)

        new_password = params[:password]
        new_password_confirmation = params[:password_confirmation]

        result = if valid_password?(current_password) && new_password.present? && new_password_confirmation.present?
                   update(params, *options)
                 else
                   assign_attributes(params, *options)
                   valid?
                   errors.add(:current_password, current_password.blank? ? :blank : :invalid)
                   errors.add(:password, new_password.blank? ? :blank : :invalid)
                   errors.add(:password_confirmation, new_password_confirmation.blank? ? :blank : :invalid)
                   false
                 end

        clean_up_passwords
        result
      end
    end
  end
end
