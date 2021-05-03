# frozen_string_literal: true

RailsApp::Application.configure do
  config.cache_classes = true
  config.eager_load = false

  config.public_file_server.enabled = true
  config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=3600' }

  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  config.action_dispatch.show_exceptions = false

  config.action_controller.allow_forgery_protection = false

  config.action_mailer.delivery_method = :test
  config.action_mailer.default_url_options = { host: 'test.host' }

  config.active_support.deprecation = :stderr
  I18n.enforce_available_locales = false

  config.active_support.test_order = :sorted
  config.log_level = :debug
  config.active_record.sqlite3.represent_boolean_as_integer = true if Rails.gem_version.release >= Gem::Version.new('5.2') && Rails.gem_version.release < Gem::Version.new('6.0')
end
ActiveSupport::Deprecation.debug = true
