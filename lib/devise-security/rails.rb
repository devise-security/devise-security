# frozen_string_literal: true

module DeviseSecurity
  class Engine < ::Rails::Engine
    ActiveSupport.on_load(:action_controller) do
      include DeviseSecurity::Controllers::Helpers
    end

    if Rails.version > '5'
      ActiveSupport::Reloader.to_prepare do
        DeviseSecurity::Patches.apply
      end
    else
      ActionDispatch::Callbacks.to_prepare do
        DeviseSecurity::Patches.apply
      end
    end
  end
end
