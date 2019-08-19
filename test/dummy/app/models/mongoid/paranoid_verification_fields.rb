module ParanoidVerificationFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document
    field :paranoid_verification_code, type: String
    field :paranoid_verified_at, type: Time
    field :paranoid_verification_attempt, type: Integer, default: 0
  end
end
