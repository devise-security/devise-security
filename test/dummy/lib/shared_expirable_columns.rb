# frozen_string_literal: true

require 'shared_user'

module SharedVerificationColumns
  extend ActiveSupport::Concern

  included do
    include SharedUser
    devise :expirable

    field :expired_at, type: Time
    field :last_activity_at, type: Time
  end
end
