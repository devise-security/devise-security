module Devise
  module Models
    module Compatibility
      module Mongoid
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
      end
    end
  end
end
