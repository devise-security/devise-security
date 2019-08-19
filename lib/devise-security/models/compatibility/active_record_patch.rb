module Devise
  module Models
    module Compatibility

      class NotPersistedError < ActiveRecord::ActiveRecordError; end

      module ActiveRecordPatch
        extend ActiveSupport::Concern
        unless Devise.activerecord51?
          # When the record was saved, was the +encrypted_password+ changed?
          # @return [Boolean]
          def saved_change_to_encrypted_password?
            encrypted_password_changed?
          end

          # The encrypted password that existed before the record was saved
          # @return [String]
          # @return [nil] if an +encrypted_password+ had not been set
          def encrypted_password_before_last_save
            previous_changes['encrypted_password'].try(:first)
          end

          # When the record is saved, will the +encrypted_password+ be changed?
          # @return [Boolean]
          def will_save_change_to_encrypted_password?
            changed_attributes['encrypted_password'].present?
          end
        end

        # Updates the record with the value and does not trigger validations or callbacks
        # @param name [Symbol] attribute to update
        # @param value [String] value to set
        def update_attribute_without_validatons_or_callbacks(name, value)
          update_column(name, value)
        end

      end
    end
  end
end
