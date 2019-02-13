# frozen_string_literal: true

ENV['RAILS_ENV'] = 'test'

require 'simplecov'
require 'coveralls'
Coveralls.wear!

unless defined?(DEVISE_ORM)
  DEVISE_ORM = (ENV["DEVISE_ORM"] || :active_record).to_sym
  #DEVISE_ORM = :mongoid
end

require 'dummy/config/environment'
require 'minitest/autorun'
require 'rails/test_help'
require 'devise-security'
if DEVISE_ORM == :mongoid
  $:.unshift File.dirname(__FILE__)
  puts "\n==> Devise.orm = #{DEVISE_ORM.inspect}" if DEVISE_ORM == :mongoid

  require 'mongoid'
  #require 'dummy/config/environment'
  require "orm/#{DEVISE_ORM}"

  #require 'minitest/autorun'
  #require 'devise-security'

  #require 'minitest/autorun'
  if DEVISE_ORM == :mongoid
    require 'mongoid'
    #require 'mongoid-minitest'
    #  require 'minitest-matchers'
    #  require 'dummy/app/models/user'

    #require 'dummy/app/models/mongoid/user_mapping'
    #User.include UserMapping
  end

  require 'devise-security'

elsif DEVISE_ORM == :active_record
  #require 'dummy/config/environment'
  #require 'minitest/autorun'
  #require 'devise-security'

  ActiveRecord::Migration.verbose = false
  ActiveRecord::Base.logger = Logger.new(nil)
  if Rails.gem_version >= Gem::Version.new('5.2.0')
    ActiveRecord::MigrationContext.new(File.expand_path('../dummy/db/migrate', __FILE__)).migrate
  else
    ActiveRecord::Migrator.migrate(File.expand_path('../dummy/db/migrate', __FILE__))
  end
end

SimpleCov.formatter = Coveralls::SimpleCov::Formatter
SimpleCov.start do
  add_filter 'test/dummy'
  add_filter 'gemfiles'
end
