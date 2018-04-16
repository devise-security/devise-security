# frozen_string_literal: true

class CaptchaUser < ActiveRecord::Base
  self.table_name = 'users'
  devise :database_authenticatable, :password_archivable,
         :paranoid_verification, :password_expirable
end
