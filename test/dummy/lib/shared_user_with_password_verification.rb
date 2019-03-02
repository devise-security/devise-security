# frozen_string_literal: true

module SharedUserWithPasswordVerification
  extend ActiveSupport::Concern

  included do
    include SharedVerificationFields
  end

  def raw_confirmation_token
    @raw_confirmation_token
  end
end
