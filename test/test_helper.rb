# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
DEVISE_ORM = ENV.fetch('DEVISE_ORM', 'active_record').to_sym

require 'simplecov'
SimpleCov.start do
  add_filter 'gemfiles'
  add_group 'Tests', 'test'
  add_group 'Password Archivable', 'password_archivable'
  add_group 'Password Expirable', 'password_expirable'
  add_group 'Session Limitable', 'session_limitable'
  add_group 'Session Traceable', 'session_traceable'
end

if ENV['CI']
  require 'coveralls'
  SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  Coveralls.wear!
end

require 'pry'
require 'dummy/config/environment'
require 'minitest/autorun'
require 'rails/test_help'
require 'devise-security'
require 'database_cleaner'
require "orm/#{DEVISE_ORM}"

class Minitest::Spec
  before(:each) do
    DatabaseCleaner.start
  end

  after(:each) do
    DatabaseCleaner.clean
  end
end

require 'mocha/setup'
require 'shoulda'
require 'timecop'
require 'webrat'
Webrat.configure do |config|
  config.mode = :rails
  config.open_error_files = false
end

DatabaseCleaner.clean

# Add support to load paths so we can overwrite broken webrat setup
$LOAD_PATH.unshift File.expand_path('support', __dir__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }
