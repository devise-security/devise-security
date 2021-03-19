# frozen_string_literal: true

module DeviseSecurity::Patches
  module SetMinimumPasswordLength
    extend ActiveSupport::Concern

    included do
      define_method :set_minimum_password_length do
        if devise_mapping.validatable? || devise_mapping.secure_validatable?
          @minimum_password_length = resource_class.password_length.min
        end
      end
    end
  end
end
