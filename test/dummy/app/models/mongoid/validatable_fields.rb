# frozen_string_literal: true

module ValidatableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document
  end
end
