# frozen_string_literal: true

require_relative 'migration_generator'

module DeviseSecurity
  module Generators
    # Base class for per-module migration generators.
    #
    # Subclasses declare their schema via +columns+ and +tables+, then this
    # base class generates the appropriate "add columns" and/or "create table"
    # migrations. Follows Devise's convention of accepting a MODEL argument
    # that defaults to +"user"+.
    #
    # @example Subclass for a module that adds columns
    #   class SessionLimitableGenerator < ModuleMigrationGenerator
    #     columns [
    #       { name: :unique_session_id, type: :string }
    #     ]
    #   end
    #
    # @example Subclass for a module that creates a table
    #   class SessionTraceableGenerator < ModuleMigrationGenerator
    #     table :session_histories, 'create_session_histories'
    #   end
    #
    # @see DeviseSecurity::MigrationGenerator
    class ModuleMigrationGenerator < ::DeviseSecurity::MigrationGenerator
      argument :model, type: :string, default: 'user',
                       desc: 'The model name (e.g., user, admin). Defaults to user.'

      class_attribute :_columns, default: []
      class_attribute :_tables, default: []
      class_attribute :_indexes, default: []

      class << self
        # Declare columns to add to the model's table.
        #
        # @param cols [Array<Hash>] column definitions with :name, :type, and optional :options
        def columns(cols)
          self._columns = cols
        end

        # Declare a separate table to create.
        #
        # @param table_name [Symbol] the table name
        # @param template_name [String] the ERB template name (without .rb.erb)
        def table(table_name, template_name)
          self._tables = _tables + [{ table_name: table_name, template: template_name }]
        end

        # Declare indexes to add.
        #
        # @param idxs [Array<Hash>] index definitions with :column and optional :options
        def indexes(idxs)
          self._indexes = idxs
        end
      end

      def create_migration_files
        create_column_migration if self.class._columns.any?
        create_table_migrations if self.class._tables.any?
      end

      protected

      # @return [String] the table name derived from the model argument
      def table_name
        model.underscore.pluralize
      end

      # @return [String] the module name derived from the generator class name
      def module_name
        self.class.name.demodulize.sub('Generator', '').underscore
      end

      # @return [Boolean] whether the database adapter is PostgreSQL
      def postgresql?
        ar_config && ar_config['adapter'] == 'postgresql'
      end

      private

      def create_column_migration
        @column_migration_name = "add_#{module_name}_to_#{table_name}"
        add_devise_security_migration(
          @column_migration_name,
          template_name: 'add_columns'
        )
      end

      # @return [String] class name for the column migration
      def migration_class_name
        @column_migration_name&.camelize
      end

      # @return [Array<Hash>] column definitions from the generator subclass
      def columns
        self.class._columns
      end

      # @return [Array<Hash>] index definitions from the generator subclass
      def indexes
        self.class._indexes
      end

      def create_table_migrations
        self.class._tables.each do |tbl|
          add_devise_security_migration(tbl[:template])
        end
      end
    end

    # @!group Module Generators

    # Adds +unique_session_id+ column to the model's table.
    # @example
    #   rails generate devise_security:session_limitable       # adds to users
    #   rails generate devise_security:session_limitable admin # adds to admins
    class SessionLimitableGenerator < ModuleMigrationGenerator
      source_root File.expand_path('templates', __dir__)

      columns [
        { name: :unique_session_id, type: :string }
      ]
    end

    # Creates the +session_histories+ table for session tracking.
    # @example
    #   rails generate devise_security:session_traceable
    class SessionTraceableGenerator < ModuleMigrationGenerator
      source_root File.expand_path('../active_record/templates', __dir__)

      table :session_histories, 'create_session_histories'
    end

    # Adds +password_changed_at+ column to the model's table.
    # @example
    #   rails generate devise_security:password_expirable
    class PasswordExpirableGenerator < ModuleMigrationGenerator
      source_root File.expand_path('templates', __dir__)

      columns [
        { name: :password_changed_at, type: :datetime }
      ]
      indexes [
        { column: :password_changed_at }
      ]
    end

    # Adds +last_activity_at+ and +expired_at+ columns to the model's table.
    # @example
    #   rails generate devise_security:expirable
    class ExpirableGenerator < ModuleMigrationGenerator
      source_root File.expand_path('templates', __dir__)

      columns [
        { name: :last_activity_at, type: :datetime },
        { name: :expired_at, type: :datetime }
      ]
      indexes [
        { column: :last_activity_at },
        { column: :expired_at }
      ]
    end

    # Adds paranoid verification columns to the model's table.
    # @example
    #   rails generate devise_security:paranoid_verification
    class ParanoidVerificationGenerator < ModuleMigrationGenerator
      source_root File.expand_path('templates', __dir__)

      columns [
        { name: :paranoid_verification_code, type: :string },
        { name: :paranoid_verification_attempt, type: :integer, options: 'default: 0' },
        { name: :paranoid_verified_at, type: :datetime }
      ]
    end

    # Creates the +old_passwords+ table for password archiving.
    # @example
    #   rails generate devise_security:password_archivable
    class PasswordArchivableGenerator < ModuleMigrationGenerator
      source_root File.expand_path('templates', __dir__)

      table :old_passwords, 'create_old_passwords'
    end

    # Adds security question columns to the model's table and creates
    # the +security_questions+ table.
    # @example
    #   rails generate devise_security:security_questionable
    class SecurityQuestionableGenerator < ModuleMigrationGenerator
      source_root File.expand_path('templates', __dir__)

      columns [
        { name: :security_question_id, type: :integer },
        { name: :security_question_answer, type: :string }
      ]
      table :security_questions, 'create_security_questions'
    end

    # @!endgroup
  end
end
