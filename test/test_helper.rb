# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
require 'coveralls'
Coveralls.wear!

require 'dummy/config/environment'
require 'minitest/autorun'
require 'rails/test_help'
require 'devise-security'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
if Rails.version == '5.2.0'
  mc = ActiveRecord::MigrationContext.new(File.expand_path('../dummy/db/migrate', __FILE__))
  mc.migrate
else
  ActiveRecord::Migrator.migrate(File.expand_path('../dummy/db/migrate', __FILE__))
end

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'test/dummy'
  add_filter 'gemfiles'
end
