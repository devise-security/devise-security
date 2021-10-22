# frozen_string_literal: true

require 'active_record'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)

if Rails.gem_version >= Gem::Version.new('6.0.0')
  ActiveRecord::MigrationContext.new(File.expand_path('../dummy/db/migrate', __dir__), ActiveRecord::SchemaMigration).migrate
elsif Rails.gem_version >= Gem::Version.new('5.2.0')
  ActiveRecord::MigrationContext.new(File.expand_path('../dummy/db/migrate', __dir__)).migrate
end

DatabaseCleaner[:active_record].strategy = :transaction
ORMInvalidRecordException = ActiveRecord::RecordInvalid
