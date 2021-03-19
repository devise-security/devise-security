# frozen_string_literal: true

class MinimumPasswordInformationController < DeviseController
  include DeviseSecurity::Patches::SetMinimumPasswordInformation
end
