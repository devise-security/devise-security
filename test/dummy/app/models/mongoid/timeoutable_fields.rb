# frozen_string_literal: true

module TimeoutableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## Timeoutable
  end
end
