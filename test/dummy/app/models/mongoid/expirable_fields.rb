# frozen_string_literal: true

module ExpirableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## Expirable
    field :expired_at, type: Time
    field :last_activity_at, type: Time
  end
end
