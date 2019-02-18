module TrackableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## Trackable
    field :sign_in_count, type: Integer, default: 0
    field :current_sign_in_at, type: Time
    field :last_sign_in_at, type: Time
    field :current_sign_in_ip, type: String
    field :last_sign_in_ip, type: String
  end
end
