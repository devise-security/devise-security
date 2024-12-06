# frozen_string_literal: true

require 'active_record'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)

if Rails.gem_version >= Gem::Version.new('7.1')
  ActiveRecord::MigrationContext.new(File.expand_path('../dummy/db/migrate', __dir__)).migrate
else
  ActiveRecord::MigrationContext.new(File.expand_path('../dummy/db/migrate', __dir__), ActiveRecord::SchemaMigration).migrate
end

DatabaseCleaner[:active_record].strategy = :transaction
ORMInvalidRecordException = ActiveRecord::RecordInvalid
