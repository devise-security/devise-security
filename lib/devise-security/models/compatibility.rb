# frozen_string_literal: true

require_relative "compatibility/#{DEVISE_ORM}"

module Devise
  module Models
    module Compatibility
      extend ActiveSupport::Concern
      include "Devise::Models::Compatibility::#{DEVISE_ORM.to_s.classify}".constantize
    end
  end
end
