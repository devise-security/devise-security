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
    # @param migration_name [String] The output migration file name
    # @param extra_options [Hash] Additional options for the migration template
    # @option extra_options [String] :template_name Override the ERB template name
    #   (defaults to migration_name). Useful when a shared template generates
    #   different output migration names.
    # @return [void]
    def add_devise_security_migration(migration_name, extra_options = {})
      migration_dir = File.expand_path('db/migrate')
      return if self.class.migration_exists?(migration_dir, migration_name)

      template_name = extra_options.delete(:template_name) || migration_name
      migration_template(
        "#{template_name}.rb.erb",
        "db/migrate/#{migration_name}.rb",
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
