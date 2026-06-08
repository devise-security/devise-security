# frozen_string_literal: true

module DeviseSecurity
  # Rails engine that integrates devise-security into the host application.
  #
  # On controller load, includes {Controllers::Helpers} into all controllers
  # (adds expired-password and paranoid-verification before-action hooks).
  #
  # On each code reload, calls {Patches.apply} to conditionally patch
  # Devise controllers with captcha and security-question support.
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include DeviseSecurity::Controllers::Helpers
    end

    ActiveSupport::Reloader.to_prepare do
      DeviseSecurity::Patches.apply
    end
  end
end
