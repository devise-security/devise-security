# frozen_string_literal: true

module DeviseSecurity::Patches
  module SetMinimumPasswordLength
    extend ActiveSupport::Concern

    included do
      define_method :set_minimum_password_length do
        if devise_mapping.validatable?
          @minimum_password_length = resource_class.password_length.min
        elsif devise_mapping.secure_validatable?
          @minimum_password_length = resource_class.password_length.min
          @minimum_password_complexity = resource_class.password_complexity
        end
      end
    end
  end
end
