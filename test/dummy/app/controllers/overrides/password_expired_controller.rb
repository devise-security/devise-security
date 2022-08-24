# frozen_string_literal: true

class Overrides::PasswordExpiredController < Devise::PasswordExpiredController
  def update
    super do |resource|
      @update_block_called = true
    end
  end

  def after_password_expired_update_path_for(_)
    '/cookies'
  end

  def update_block_called?
    @update_block_called == true
  end
end
