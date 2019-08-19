# frozen_string_literal: true

require File.expand_path('../boot', __FILE__)

require 'action_mailer/railtie'
require "action_mailer/railtie"
require "rails/test_unit/railtie"
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

    config.assets.enabled = true

    config.assets.version = '1.0'
    config.secret_key_base = 'fuuuuuuuuuuu'
  end
end
