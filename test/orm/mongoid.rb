# frozen_string_literal: true

require 'mongoid/version'
require 'database_cleaner-mongoid'

Mongoid.configure do |config|
  config.load!('test/support/mongoid.yml', Rails.env)
  config.use_utc = true
  config.include_root_in_json = true
end

DatabaseCleaner[:mongoid].strategy = :deletion
ORMInvalidRecordException = Mongoid::Errors::Validations
