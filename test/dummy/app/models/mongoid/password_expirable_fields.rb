module PasswordExpirableFields
  # def self.included(base)

  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    field :expired_at, type: Time
    field :last_activity_at, type: Time
  end

  module ClassMethods

  end

end
