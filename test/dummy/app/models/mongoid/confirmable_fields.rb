# frozen_string_literal: true

module ConfirmableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## Confirmable
    field :confirmation_token, type: String
    field :confirmed_at, type: Time
    field :confirmation_sent_at, type: Time
    field :unconfirmed_email, type: String # Only if using reconfirmable
  end
end
