# frozen_string_literal: true

module Devise
  module Models
    module AuthenticatablePatch

      #module ClassMethods
      def find_first_by_auth_conditions(tainted_conditions, opts = {})
        to_adapter.find_first(devise_parameter_filter.filter(tainted_conditions).merge(opts))
      end
      #end
    end
  end
end
