# frozen_string_literal: true
require 'shared_user'

module SharedVerificationFields
  extend ActiveSupport::Concern

  included do
    include SharedUser
    devise :paranoid_verification

    field :paranoid_verified_at, type: Time
    field :paranoid_verification_attempt, type: Integer, default: 0
    field :paranoid_verification_code, type: String
  end
end
