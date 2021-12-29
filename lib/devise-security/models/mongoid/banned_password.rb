# frozen_string_literal: true

class BannedPassword
  include Mongoid::Document
  include Mongoid::Timestamps

  field :password, type: String
  validates_presence_of :password
  index({ password: 1 }, name: 'index_banned_password_password')
end
