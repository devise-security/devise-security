module DatabaseAuthenticatableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## Database authenticatable
    field :username, type: String
    field :email, type: String, default: ""
    #validates_presence_of :email

    field :encrypted_password, type: String, default: ""
    validates_presence_of :encrypted_password

    include Mongoid::Timestamps
  end
end
