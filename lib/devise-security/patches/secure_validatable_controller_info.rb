# frozen_string_literal: true

module DeviseSecurity
  module Patches
    # Extends +DeviseController#set_minimum_password_length+ to also expose
    # +@minimum_password_length+ and +@minimum_password_complexity+ when
    # the model uses +:secure_validatable+ instead of (or in addition to)
    # +:validatable+.
    #
    # Without this patch, views that reference +@minimum_password_length+
    # (e.g., Devise's registration and password forms) show +nil+ when the
    # model only uses +:secure_validatable+, because the original method
    # only checks +devise_mapping.validatable?+.
    #
    # @see https://github.com/devise-security/devise-security/issues/290
    module SecureValidatableControllerInfo
      extend ActiveSupport::Concern

      # Override +set_minimum_password_length+ to also handle
      # +:secure_validatable+ mappings.
      #
      # When the devise mapping includes +:secure_validatable+, sets:
      # - +@minimum_password_length+ from +resource_class.password_length.min+
      # - +@minimum_password_complexity+ from +resource_class.password_complexity+
      #
      # Falls through to the original implementation for +:validatable+
      # mappings so existing behavior is preserved.
      #
      # @return [void]
      def set_minimum_password_length
        super

        return unless devise_mapping.secure_validatable?

        @minimum_password_length ||= resource_class.password_length.min
        @minimum_password_complexity = resource_class.password_complexity
      end
    end
  end
end
