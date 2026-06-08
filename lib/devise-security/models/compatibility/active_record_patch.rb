# frozen_string_literal: true

module Devise
  module Models
    module Compatibility
      class NotPersistedError < ActiveRecord::ActiveRecordError; end

      module ActiveRecordPatch
        extend ActiveSupport::Concern

        # Updates the record with the value and does not trigger validations or callbacks
        # @param name [Symbol] attribute to update
        # @param value [String] value to set
        def update_attribute_without_validatons_or_callbacks(name, value)
          update_column(name, value)
        end
      end
    end
  end
end
