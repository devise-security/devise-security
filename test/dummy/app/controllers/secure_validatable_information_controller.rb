# frozen_string_literal: true

class SecureValidatableInformationController < DeviseController
  def index
    set_minimum_password_length

    head :ok
  end
end
