# frozen_string_literal: true

module DatabaseAuthenticatableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## Database authenticatable
    field :username, type: String
    field :email, type: String, default: ''

    field :encrypted_password, type: String, default: ''
    validates :encrypted_password, presence: true

    include Mongoid::Timestamps
  end
end
