require 'active_record'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
if Rails.gem_version >= Gem::Version.new('5.2.0')
  ActiveRecord::MigrationContext.new(File.expand_path('../../dummy/db/migrate', __FILE__)).migrate
else
  ActiveRecord::Migrator.migrate(File.expand_path('../../dummy/db/migrate', __FILE__))
end
