module OmniauthableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## Omniautable
    field :username, type: String
    field :facebook_token, type: String
  end
end
