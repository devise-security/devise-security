# frozen_string_literal: true

class ParanoidVerificationUser < ApplicationUserRecord
  devise :database_authenticatable, :paranoid_verification

  if DEVISE_ORM == :mongoid
    require './test/dummy/app/models/mongoid/mappings'
    include ::Mongoid::Mappings
  end
end
