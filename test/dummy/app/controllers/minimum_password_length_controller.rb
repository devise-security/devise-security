# frozen_string_literal: true

class MinimumPasswordLengthController < DeviseController
  include DeviseSecurity::Patches::SetMinimumPasswordLength
end
