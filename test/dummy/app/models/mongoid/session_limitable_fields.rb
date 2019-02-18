module SessionLimitableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## Session Limitable
    field :unique_session_id, type: String
  end
end
