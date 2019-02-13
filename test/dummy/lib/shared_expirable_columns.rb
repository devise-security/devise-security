# frozen_string_literal: true
require 'shared_user'

module SharedVerificationColumns
  extend ActiveSupport::Concern

  included do
    include SharedUser
    devise :expirable

    field :expired_at, type: Time
    field :last_activity_at, type: Time

    # They need to be included after Devise is called.
    extend ExtendMethods
  end

  module ExtendMethods

  end
end
