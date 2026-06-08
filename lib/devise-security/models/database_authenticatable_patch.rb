# frozen_string_literal: true

module Devise
  module Models
    # Patches Devise's +DatabaseAuthenticatable#update_with_password+ to require
    # both a new password AND its confirmation before saving. The upstream Devise
    # implementation allows updating non-password attributes when only
    # +current_password+ is provided; this patch rejects the update unless all
    # three fields (+current_password+, +password+, +password_confirmation+) are
    # present and valid.
    module DatabaseAuthenticatablePatch
      # Update the record with password-protected attribute changes.
      # Requires +current_password+, +password+, and +password_confirmation+
      # to all be present. Adds individual errors for each missing field.
      #
      # @param params [Hash] attributes to update, must include +:current_password+,
      #   +:password+, and +:password_confirmation+
      # @param options [Array] additional arguments forwarded to +update+/+assign_attributes+
      # @return [Boolean] true if the record was saved, false otherwise
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
