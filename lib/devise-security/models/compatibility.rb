# frozen_string_literal: true

require_relative "compatibility/#{DEVISE_ORM}_patch"

module Devise
  module Models
    # ORM compatibility layer for devise-security. Defines (or redefines) methods
    # that differ between ActiveRecord and Mongoid so that other devise-security
    # modules can use a uniform API regardless of the ORM in use.
    #
    # ORM-specific patches live in +compatibility/active_record_patch.rb+ and
    # +compatibility/mongoid_patch.rb+. The correct one is loaded at require
    # time based on the +DEVISE_ORM+ constant set by Devise.
    module Compatibility
      extend ActiveSupport::Concern

      # Dynamically include the ORM-specific patch module. For example, when
      # +DEVISE_ORM+ is +:active_record+, this resolves to
      # +Devise::Models::Compatibility::ActiveRecordPatch+.
      include "Devise::Models::Compatibility::#{DEVISE_ORM.to_s.classify}Patch".constantize
    end
  end
end
