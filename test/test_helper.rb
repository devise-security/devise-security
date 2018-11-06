# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start do
  add_filter 'gemfiles'
  add_group 'Tests', 'test'
  add_group 'Password Expireable', "password_expirable"
  add_group 'Secure Validateable', 'secure_validatable'
end

if ENV['CI']
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  Coveralls.wear!
end

require 'dummy/config/environment'
require 'minitest/autorun'
require 'rails/test_help'

require 'devise-security'
require 'pry'

ActiveRecord::Migration.verbose = false
ActiveRecord::Base.logger = Logger.new(nil)
if Rails.gem_version >= Gem::Version.new('5.2.0')
  ActiveRecord::MigrationContext.new(File.expand_path('../dummy/db/migrate', __FILE__)).migrate
else
  ActiveRecord::Migrator.migrate(File.expand_path('../dummy/db/migrate', __FILE__))
end
