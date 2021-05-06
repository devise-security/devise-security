# frozen_string_literal: true

module DeviseSecurity::Patches
  module SecureValidatableInformation
    extend ActiveSupport::Concern

    included do
      alias_method(
        :original_set_minimum_password_length, :set_minimum_password_length
      )

      define_method :set_minimum_password_length do
        if devise_mapping.secure_validatable?
          @minimum_password_length = resource_class.password_length.min
          @minimum_password_complexity = resource_class.password_complexity
        end
        original_set_minimum_password_length
      end
    end
  end
end
