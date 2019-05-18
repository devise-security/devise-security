module LockableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
    field :unlock_token, type: String # Only if unlock strategy is :email or :both
    field :locked_at, type: Time
    include Mongoid::Timestamps
    index({ unlock_token: 1 }, { unique: true })
  end
end
