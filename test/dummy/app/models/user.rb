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
         :session_traceable,
         :timeoutable,
         :validatable

  has_many :widgets

  if DEVISE_ORM == :mongoid
    require './test/dummy/app/models/mongoid/mappings'
    include ::Mongoid::Mappings
  end
end
