# frozen_string_literal: true

require File.expand_path('boot', __dir__)

require 'action_mailer/railtie'
require 'rails/test_unit/railtie'
DEVISE_ORM = ENV.fetch('DEVISE_ORM', 'active_record').to_sym

Bundler.require :default, DEVISE_ORM
require "#{DEVISE_ORM}/railtie"

require 'rails/all'
require 'devise-security'

module RailsApp
  class Application < Rails::Application
    config.encoding = 'utf-8'

    config.filter_parameters += [:password]

    config.autoload_paths += ["#{config.root}/app/#{DEVISE_ORM}"]
    config.autoload_paths += ["#{config.root}/lib"]

    if Rails.gem_version < Gem::Version.new('7.0.0')
      config.assets.enabled = true
      config.assets.version = '1.0'
    end

    config.secret_key_base = 'foobar'
  end
end
