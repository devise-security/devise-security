# # frozen_string_literal: true
#
# ActiveRecord::Migration.verbose = false
# ActiveRecord::Base.logger = Logger.new(nil)
# ActiveRecord::Base.include_root_in_json = true
#
# migrate_path = File.expand_path('../../dummy/db/migrate', __FILE__)
#
# if defined?(Devise::Test.rails52?) && Devise::Test.rails52?
#   ActiveRecord::MigrationContext.new(migrate_path).migrate
# elsif Rails.gem_version >= Gem::Version.new('5.2.0')
#   ActiveRecord::MigrationContext.new(migrate_path).migrate
# else
#   ActiveRecord::Migrator.migrate(migrate_path)
# end
#
# class ActiveSupport::TestCase
#   if defined?(Devise::Test.rails52?) && Devise::Test.rails52?
#     self.use_transactional_tests = true
#     self.use_transactional_fixtures = true
#     self.use_instantiated_fixtures  = false
#   elsif Rails.gem_version >= Gem::Version.new('5.2.0')
#     #self.use_transactional_tests = true
#   else
#     # Let `after_commit` work with transactional fixtures, however this is not needed for Rails 5.
#     require 'test_after_commit'
#     #self.use_transactional_fixtures = true
#   end
# end
