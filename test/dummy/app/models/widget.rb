# frozen_string_literal: true

class Widget < ApplicationRecord
  belongs_to :user
  validates_associated :user
end
