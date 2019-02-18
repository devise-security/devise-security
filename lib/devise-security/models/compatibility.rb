# frozen_string_literal: true

module Devise
  module Models
    module Compatibility
      extend ActiveSupport::Concern

      if DEVISE_ORM == :active_record
        # for backwards compatibility with Rails < 5.1.xi
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
      elsif DEVISE_ORM == :mongoid
        def will_save_change_to_email?
          changed.include? 'email'
        end

        def will_save_change_to_encrypted_password?
          changed.include? 'encrypted_password'
        end
      end
    end
  end
end
