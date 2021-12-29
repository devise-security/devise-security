# frozen_string_literal: true

module PasswordBannableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document
  end
end
