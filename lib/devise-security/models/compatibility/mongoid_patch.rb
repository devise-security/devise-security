module Devise
  module Models
    module Compatibility

      class NotPersistedError < Mongoid::Errors::MongoidError; end

      module MongoidPatch
        extend ActiveSupport::Concern

        # Will saving this record change the +email+ attribute?
        # @return [Boolean]
        def will_save_change_to_email?
          changed.include? 'email'
        end

        # Will saving this record change the +encrypted_password+ attribute?
        # @return [Boolean]
        def will_save_change_to_encrypted_password?
          changed.include? 'encrypted_password'
        end

        # Updates the document with the value and does not trigger validations or callbacks
        # @param name [Symbol] attribute to update
        # @param value [String] value to set
        def update_attribute_without_validatons_or_callbacks(name, value)
          set(Hash[*[name, value]])
        end
      end
    end
  end
end
