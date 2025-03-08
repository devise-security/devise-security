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
  config.active_record.legacy_connection_handling = false if (Gem::Version.new('6.1')...Gem::Version.new('7.1')).cover?(Rails.gem_version)
end

if Rails.gem_version <= Gem::Version.new('7.1')
  ActiveSupport::Deprecation.debug = true
else
  Rails.application.deprecators.debug = true
end

if Rails.gem_version >= Gem::Version.new('8.0')
  # Eager loading routes here helps to avoid issues where Devise Mappings are not loaded in Rails 8.0
  RailsApp::Application.routes.eager_load!
end
