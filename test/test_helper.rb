# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'

require 'simplecov'
SimpleCov.start do
  add_filter 'gemfiles'
  add_group 'Tests', 'test'
  add_group 'Password Archivable', 'password_archivable'
  add_group 'Password Expirable', 'password_expirable'
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

class Minitest::Test
  def before_setup
    DatabaseCleaner.start
  end

  def after_teardown
    DatabaseCleaner.clean
  end
end

DatabaseCleaner.clean
