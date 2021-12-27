# frozen_string_literal: true

class Overrides::ParanoidVerificationCodeController < Devise::ParanoidVerificationCodeController
  def after_paranoid_verification_code_update_path_for(_)
    '/cats'
  end
end
