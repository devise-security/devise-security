# frozen_string_literal: true

require File.expand_path('../boot', __FILE__)

unless defined? DEVISE_ORM
  DEVISE_ORM = ENV.fetch('DEVISE_ORM',  'active_record').to_sym
end
if DEVISE_ORM == :active_record
  require 'rails/all'
  require 'devise-security'
elsif DEVISE_ORM == :mongoid
  require "rails"
  require "#{DEVISE_ORM}"
  require 'devise-security'

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
