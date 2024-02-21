# frozen_string_literal: true

require 'test_helper'

if DEVISE_ORM == :active_record
  require 'generators/devise_security/migration_generator'

  class TestMigrationGenerator < Rails::Generators::TestCase
    class Migration < ::DeviseSecurity::MigrationGenerator
      source_root File.expand_path('templates', __dir__)

      def create_migration_file
        add_devise_security_migration 'create_some_table'
      end
    end

    tests Migration
    destination File.expand_path('../dummy/tmp', __dir__)
    setup :prepare_destination

    test 'all files are properly created with migration syntax' do
      assert_nothing_raised { run_generator }
      assert_migration 'db/migrate/create_some_table.rb', /create_table :some_table do |t|/
    end
  end
end
