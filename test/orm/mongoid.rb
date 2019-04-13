# frozen_string_literal: true

require 'mongoid/version'

Mongoid.configure do |config|
  config.load!('test/support/mongoid.yml', Rails.env)
  config.use_utc = true
  config.include_root_in_json = true
end

class ActiveSupport::TestCase
  setup do
    if Mongoid.respond_to?(:default_session)
      Mongoid.default_session.drop
    else
      Mongoid.default_client.database.drop
    end
  end
end

DatabaseCleaner[:mongoid].strategy = :truncation
ORMInvalidRecordException = Mongoid::Errors::Validations
