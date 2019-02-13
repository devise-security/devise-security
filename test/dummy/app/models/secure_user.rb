# frozen_string_literal: true

class SecureUser < ApplicationRecord
  devise :database_authenticatable, :secure_validatable, email_validation: false
  if DEVISE_ORM == :mongoid
    require './test/dummy/app/models/mongoid/mappings'
    include Mongoid::Mappings
  end
end
