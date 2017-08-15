class SecurityQuestion::UnlocksController < Devise::UnlocksController
  include DeviseSecurity::Patches::ControllerSecurityQuestion
end
