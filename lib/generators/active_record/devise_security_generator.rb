# frozen_string_literal: true

require 'rails/generators/active_record'
require 'generators/devise/orm_helpers'

module ActiveRecord
  module Generators
    class DeviseSecurityGenerator < Base
      source_root File.expand_path('templates', __dir__)

      def copy_migration_file
        migration_template 'session_histories.rb.erb',
                           "db/migrate/create_#{table_name}.rb",
                           migration_version: migration_version,
                           ip_column: ip_column
      end

      def ip_column
        postgresql? ? 'inet' : 'string'
      end

      def postgresql?
        config = ActiveRecord::Base.configurations[Rails.env]
        config && config['adapter'] == 'postgresql'
      end

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" unless Rails.version.start_with?('4')
      end
    end
  end
end
