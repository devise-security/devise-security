# frozen_string_literal: true

module SecureValidatableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    field :password_changed_at, type: Time
    index({ password_changed_at: 1 }, {})
    include Mongoid::Timestamps
  end
end
