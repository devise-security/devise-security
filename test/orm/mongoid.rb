# frozen_string_literal: true

require 'mongoid/version'

Mongoid.configure do |config|
  config.load!('test/support/mongoid.yml', Rails.env)
  config.use_utc = true
  config.include_root_in_json = true
end

DatabaseCleaner[:mongoid].strategy = :truncation
ORMInvalidRecordException = Mongoid::Errors::Validations
