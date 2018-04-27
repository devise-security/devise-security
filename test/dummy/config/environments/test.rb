# frozen_string_literal: true

RailsApp::Application.configure do
  config.cache_classes = true
  config.eager_load = false

  if Rails.version > '5'
    config.public_file_server.enabled = true
    config.public_file_server.headers = { 'Cache-Control' => 'public, max-age=3600' }
  else
    config.serve_static_files = true
    config.static_cache_control = 'public, max-age=3600'
  end

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
  if Rails.gem_version >= Gem::Version.new('4.2') && Rails.gem_version < Gem::Version.new('5.0')
    config.active_record.raise_in_transactional_callbacks = true
  end
  if Rails.gem_version.release >= Gem::Version.new('5.2')
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end
end
ActiveSupport::Deprecation.debug = true
