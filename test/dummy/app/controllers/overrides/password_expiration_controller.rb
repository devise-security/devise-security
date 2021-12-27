# frozen_string_literal: true

class Overrides::PasswordExpirationController < Devise::PasswordExpiredController
  def after_password_expiration_update_path_for(_)
    '/cookies'
  end
end
