# frozen_string_literal: true

module SessionTraceableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document
  end
end
