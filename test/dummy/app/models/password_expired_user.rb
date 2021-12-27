# frozen_string_literal: true

class PasswordExpiredUser < ApplicationUserRecord
  devise :database_authenticatable, :password_expirable

  if DEVISE_ORM == :mongoid
    require './test/dummy/app/models/mongoid/mappings'
    include ::Mongoid::Mappings
  end
end
