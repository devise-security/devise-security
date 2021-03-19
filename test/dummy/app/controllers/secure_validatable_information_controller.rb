# frozen_string_literal: true

class SecureValidatableInformationController < DeviseController
  include DeviseSecurity::Patches::SecureValidatableInformation
end
