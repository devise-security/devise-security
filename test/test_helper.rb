# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start do
  add_filter 'gemfiles'
  add_filter 'test/dummy/db'
  add_group 'ActiveRecord', 'active_record'
  add_group 'Expirable', /(?<!password_)expirable/
  add_group 'Mongoid', 'mongoid'
  add_group 'Paranoid Verifiable', 'paranoid_verification'
  add_group 'Password Archivable', /password_archivable|old_password/
  add_group 'Password Expirable', /password_expirable|password_expired/
  add_group 'Secure Validateable', 'secure_validatable'
  add_group 'Security Questionable', 'security_question'
  add_group 'Session Limitable', 'session_limitable'
  add_group 'Tests', 'test'
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
require 'support/integration_helpers'

class Minitest::Test
  def before_setup
    DatabaseCleaner.start
  end

  def after_teardown
    DatabaseCleaner.clean
  end
end

DatabaseCleaner.clean
