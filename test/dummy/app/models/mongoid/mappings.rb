# frozen_string_literal: true

Dir[File.expand_path('*_fields.rb', __dir__)].each { |f| require_relative f }

module Mongoid
  module Mappings
    extend ::ActiveSupport::Concern

    included do
      devise_modules.each do |devise_module_name|
        include "#{devise_module_name.to_s.classify}Fields".constantize
      end
    end
  end
end
