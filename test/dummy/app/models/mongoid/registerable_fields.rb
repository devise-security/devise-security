# frozen_string_literal: true

module RegisterableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## Database authenticatable
    field :email, type: String, default: ''
    validates :email, presence: true

    field :encrypted_password, type: String, default: ''
    validates :encrypted_password, presence: true

    field :password_changed_at, type: Time
    index({ password_changed_at: 1 }, {})
    index({ email: 1 }, {})
    include Mongoid::Timestamps
  end
end
