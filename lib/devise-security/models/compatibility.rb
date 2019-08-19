# frozen_string_literal: true

require_relative "compatibility/#{DEVISE_ORM}_patch"

module Devise
  module Models
    # These compatibility modules define methods used by devise-security
    # that may need to be defined or re-defined for compatibility between ORMs
    # and/or older versions of ORMs.
    module Compatibility
      extend ActiveSupport::Concern
      include "Devise::Models::Compatibility::#{DEVISE_ORM.to_s.classify}Patch".constantize
    end
  end
end
