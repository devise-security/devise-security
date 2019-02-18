# frozen_string_literal: true

class Widget < ApplicationRecord
  belongs_to :user
  validates_associated :user

  if DEVISE_ORM == :mongoid
    field :name, type: String
  end
end
