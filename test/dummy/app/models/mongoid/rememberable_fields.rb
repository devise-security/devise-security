# frozen_string_literal: true

module RememberableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## Rememberable
    field :remember_created_at, type: Time
  end
end
