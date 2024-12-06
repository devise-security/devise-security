# frozen_string_literal: true

require 'rails/generators'
require 'rails/generators/active_record'

# nodoc
module DeviseSecurity
  # Basic structure to support a generator that builds a migration
  class MigrationGenerator < ::Rails::Generators::Base
    include ::Rails::Generators::Migration

    # Implement the required interface for Rails::Generators::Migration.
    def self.next_migration_number(dirname)
      ::ActiveRecord::Generators::Base.next_migration_number(dirname)
    end

    protected

    # Creates a devise security migration template.
    #
    # @param template [String] The name of the migration template
    # @param extra_options [Hash] The options Additional options for the migration template (default: {})
    # @return [void]
    def add_devise_security_migration(template, extra_options = {})
      migration_dir = File.expand_path('db/migrate')
      return if self.class.migration_exists?(migration_dir, template)

      migration_template(
        "#{template}.rb.erb",
        "db/migrate/#{template}.rb",
        { migration_version: migration_version }.merge(extra_options)
      )
    end

    # Retrieves the ActiveRecord configuration
    def ar_config
      ActiveRecord::Base.configurations.configs_for(env_name: Rails.env, name: 'primary').configuration_hash
    end

    # Retrieves the migration version
    def migration_version
      format(
        '[%<major>s.%<minor>s]',
        major: ActiveRecord::VERSION::MAJOR,
        minor: ActiveRecord::VERSION::MINOR
      )
    end
  end
end
