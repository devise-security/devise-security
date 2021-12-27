# frozen_string_literal: true

class Overrides::ParanoidVerificationCodeController < Devise::ParanoidVerificationCodeController
  def after_password_expired_update_path_for(_)
    '/cookies'
  end
end
