# frozen_string_literal: true

module PasswordExpirableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    field :expired_at, type: Time
    field :last_activity_at, type: Time
  end
end
