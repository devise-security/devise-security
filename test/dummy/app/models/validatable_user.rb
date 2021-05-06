# frozen_string_literal: true

class ValidatableUser < ApplicationUserRecord
  devise :database_authenticatable, :validatable
  if DEVISE_ORM == :mongoid
    require './test/dummy/app/models/mongoid/mappings'
    include ::Mongoid::Mappings
  end

  def email_required?
    false
  end
end
