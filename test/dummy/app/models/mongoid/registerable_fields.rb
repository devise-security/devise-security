module RegisterableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## Database authenticatable
    field :email, type: String, default: ""
    validates_presence_of :email

    field :encrypted_password, type: String, default: ""
    validates_presence_of :encrypted_password

    field :password_changed_at, type: Time
    index({ password_changed_at: 1 }, {})
    index({ email: 1 }, {})
    include Mongoid::Timestamps
  end
end
