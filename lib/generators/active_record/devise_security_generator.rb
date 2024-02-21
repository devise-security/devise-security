# frozen_string_literal: true

require_relative '../devise_security/migration_generator'

# nodoc
module ActiveRecord
  # nodoc
  module Generators
    # Generator migration for DeviseSecurity
    # Usage:
    #  rails generate active_record:devise_security
    class DeviseSecurityGenerator < ::DeviseSecurity::MigrationGenerator
      source_root File.expand_path('templates', __dir__)

      def create_migration_file
        # TODO: Add some migration here
        # add_devise_security_migration 'some_migration_template'
      end
    end
  end
end
