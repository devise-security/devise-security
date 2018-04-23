# frozen_string_literal: true

class User < ApplicationRecord

  devise :database_authenticatable,
         :confirmable,
         :expirable,
         :lockable,
         :omniauthable,
         :paranoid_verification,
         :password_archivable,
         :password_expirable,
         :recoverable,
         :registerable,
         :rememberable,
         :secure_validatable,
         :security_questionable,
         :session_limitable,
         :timeoutable,
         :trackable,
         :validatable

  has_many :widgets
end
