# frozen_string_literal: true

class SecurityQuestion::UnlocksController < Devise::UnlocksController
  include DeviseSecurity::Patches::ControllerSecurityQuestion
end
