# frozen_string_literal: true

class CaptchaUser < ApplicationUserRecord
  devise :database_authenticatable, :password_archivable,
         :paranoid_verification, :password_expirable
  if DEVISE_ORM == :mongoid
    require './test/dummy/app/models/mongoid/mappings'
    include ::Mongoid::Mappings
  end
end
