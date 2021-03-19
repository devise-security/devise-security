# frozen_string_literal: true

class NonValidatableUser < ApplicationUserRecord
  devise :database_authenticatable
  if DEVISE_ORM == :mongoid
    require './test/dummy/app/models/mongoid/mappings'
    include ::Mongoid::Mappings
  end
end
