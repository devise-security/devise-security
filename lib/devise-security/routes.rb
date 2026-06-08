# frozen_string_literal: true

module ActionDispatch::Routing
  class Mapper
    protected

    # Adds routes for the password-expired flow (show form + update password).
    # Registered by +Devise.add_module :password_expirable, route: :password_expired+.
    #
    # Generates a singular resource with +show+ and +update+ actions:
    #   GET  /users/password_expired  => password_expired#show
    #   PUT  /users/password_expired  => password_expired#update
    #
    # @param mapping [Devise::Mapping] the Devise mapping for the scope
    # @param controllers [Hash{Symbol => String}] controller overrides;
    #   uses +controllers[:password_expired]+ for the controller name
    # @return [void]
    def devise_password_expired(mapping, controllers)
      resource :password_expired, only: %i[show update], path: mapping.path_names[:password_expired], controller: controllers[:password_expired]
    end

    # Adds routes for the paranoid verification code flow (show form + verify code).
    # Registered by +Devise.add_module :paranoid_verification, route: :verification_code+.
    #
    # Generates a singular resource with +show+ and +update+ actions:
    #   GET  /users/paranoid_verification_code  => paranoid_verification_code#show
    #   PUT  /users/paranoid_verification_code  => paranoid_verification_code#update
    #
    # @param mapping [Devise::Mapping] the Devise mapping for the scope
    # @param controllers [Hash{Symbol => String}] controller overrides;
    #   uses +controllers[:paranoid_verification_code]+ for the controller name
    # @return [void]
    def devise_verification_code(mapping, controllers)
      resource :paranoid_verification_code, only: %i[show update], path: mapping.path_names[:verification_code], controller: controllers[:paranoid_verification_code]
    end
  end
end
