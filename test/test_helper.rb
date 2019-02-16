# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
DEVISE_ORM = ENV.fetch('DEVISE_ORM',  'active_record').to_sym

require 'simplecov'
SimpleCov.start do
  add_filter 'gemfiles'
  add_group 'Tests', 'test'
  add_group 'Password Expireable', "password_expirable"
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
require "orm/#{DEVISE_ORM}"
