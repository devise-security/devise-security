# frozen_string_literal: true

require 'active_record'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)

ActiveRecord::MigrationContext.new(File.expand_path('../dummy/db/migrate', __dir__)).migrate

DatabaseCleaner[:active_record].strategy = :transaction
ORMInvalidRecordException = ActiveRecord::RecordInvalid
