# frozen_string_literal: true

module DeviseSecurity::Patches
  module SetMinimumPasswordInformation
    extend ActiveSupport::Concern

    included do
      define_method :set_secure_validatable_password_information do
        if devise_mapping.secure_validatable?
          @minimum_password_length = resource_class.password_length.min
          @minimum_password_complexity = resource_class.password_complexity
        end
      end
    end
  end
end
