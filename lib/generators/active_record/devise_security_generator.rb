# frozen_string_literal: true

require_relative '../devise_security/migration_generator'

# nodoc
module ActiveRecord
  module Generators
    # Generator migration for DeviseSecurity
    # Usage:
    #  rails generate active_record:devise_security
    class DeviseSecurityGenerator < ::DeviseSecurity::MigrationGenerator
      source_root File.expand_path('templates', __dir__)

      def create_migration_file
        add_devise_security_migration 'create_session_histories'
      end

      def postgresql?
        ar_config && ar_config['adapter'] == 'postgresql'
      end
    end
  end
end
