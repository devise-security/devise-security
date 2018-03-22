class CaptchaUser < ApplicationRecord
  self.table_name = 'users'
  devise :database_authenticatable, :password_archivable,
         :paranoid_verification, :password_expirable
end
