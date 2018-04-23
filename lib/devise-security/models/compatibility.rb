# frozen_string_literal: true

module Devise
  module Models
    module Compatibility
      extend ActiveSupport::Concern

      # for backwards compatibility with Rails < 5.1.x
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
