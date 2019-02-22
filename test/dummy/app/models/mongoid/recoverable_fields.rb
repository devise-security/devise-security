module RecoverableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## Recoverable
    field :reset_password_token, type: String
    field :reset_password_sent_at, type: Time
  end
end
