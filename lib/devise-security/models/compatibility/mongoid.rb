module Devise
  module Models
    module Compatibility
      module Mongoid
        extend ActiveSupport::Concern

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
