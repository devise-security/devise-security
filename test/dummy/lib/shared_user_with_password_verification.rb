# frozen_string_literal: true

module SharedUserWithPasswordVerification
  extend ActiveSupport::Concern

  included do
    include SharedVerificationFields

    extend ExtendMethods
  end

  def raw_confirmation_token
    @raw_confirmation_token
  end

  module ExtendMethods

  end
end
