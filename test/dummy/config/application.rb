# frozen_string_literal: true

require File.expand_path('../boot', __FILE__)

unless defined? DEVISE_ORM
  DEVISE_ORM = (ENV["DEVISE_ORM"] || :active_record).to_sym
  #DEVISE_ORM = :mongoid
end
if DEVISE_ORM == :active_record
  require 'rails/all'
  require 'devise-security'
elsif DEVISE_ORM == :mongoid
  require "rails"
  require "#{DEVISE_ORM}"
  require 'devise-security'
  all_railties = [
    'active_model/railtie',
    "#{DEVISE_ORM}/railtie",
    'active_job/railtie',
    'action_controller/railtie',
    'action_mailer/railtie',
    'action_view/railtie',
    'sprockets/railtie',
    #'rails/test_unit/railtie',
    #'active_storage/engine',
    #'action_cable/engine',
  ]
  #all_rails = all_rails.unshift 'active_record/railtie' if DEVISE_ORM && DEVISE_ORM != :mongoid
  #all_railties.select! {|railtie| !railtie.include?('active_record')} if DEVISE_ORM && DEVISE_ORM == :mongoid
  all_railties.each do |railtie|
    begin
      #require railtie
    rescue LoadError
    end
  end

#these are needed
  if defined?(Bundler)
    Bundler.require :default, DEVISE_ORM
  end
  begin
    require "#{DEVISE_ORM}/railtie"
  rescue LoadError
  end
  require 'sprockets/railtie'
  require 'action_mailer/railtie'
  require 'devise-security'
end

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(assets: %w[development test]))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module RailsApp
  class Application < Rails::Application
    config.encoding = 'utf-8'

    config.filter_parameters += [:password]

    config.autoload_paths += ["#{config.root}/app/#{DEVISE_ORM}"]
    config.autoload_paths += ["#{config.root}/lib"]

    config.assets.enabled = true

    config.assets.version = '1.0'
    config.secret_key_base = 'fuuuuuuuuuuu'
  end
end
