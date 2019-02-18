module Devise
  module Models
    module Compatibility
      module ActiveRecord
        extend ActiveSupport::Concern
        unless Devise.activerecord51?
          def saved_change_to_encrypted_password?
            encrypted_password_changed?
          end

          def encrypted_password_before_last_save
            previous_changes['encrypted_password'].try(:first)
          end

          def will_save_change_to_encrypted_password?
            changed_attributes['encrypted_password'].present?
          end
        end
      end
    end
  end
end
