# frozen_string_literal: true

ENV['RAILS_ENV'] ||= 'test'
ENV['DEVISE_ORM'] ||= 'active_record'

require 'simplecov'

if ENV['CI']
  require 'simplecov-lcov'
  SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
  SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
end

SimpleCov.start do
  add_filter %r{^/gemfiles/}
  add_filter %r{^/test/dummy/}
  if ENV['DEVISE_ORM'] == 'active_record'
    add_filter %r{/mongoid/}
  else
    add_filter %r{^/lib/generators/(active_record|migration_generator)}
    add_filter %r{^/test/generators}
    add_filter %r{/active_record/}
  end
  add_group 'ActiveRecord', 'active_record'
  add_group 'Expirable', /(?<!password_)expirable/
  add_group 'Mongoid', 'mongoid'
  add_group 'Paranoid Verifiable', 'paranoid_verification'
  add_group 'Password Archivable', /password_archivable|old_password/
  add_group 'Password Expirable', /password_expirable|password_expired/
  add_group 'Secure Validateable', 'secure_validatable'
  add_group 'Security Questionable', 'security_question'
  add_group 'Session Limitable', 'session_limitable'
  add_group 'Session Traceable', 'session_traceable'
  add_group 'Tests', 'test'
end

require 'pry'
require 'dummy/config/environment'
require 'minitest/autorun'
require 'rails/test_help'
require 'devise-security'
require 'database_cleaner'
require 'factory_bot'

# Configure FactoryBot for gem test suite (not Rails app)
FactoryBot.definition_file_paths = [File.expand_path('factories', __dir__)]
FactoryBot.find_definitions
require "orm/#{DEVISE_ORM}"

# Controller testing is the way that Devise itself tests the functionality of
# controller, even though it has been deprecated in favor of request tests.
require 'rails-controller-testing'
Rails::Controller::Testing.install

# Add support to load paths so we can overwrite broken test setup
$LOAD_PATH.unshift File.expand_path('support', __dir__)
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Shared test helpers available to all test cases.
class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods

  # Clear Devise class-level instance variables that override global config.
  # Useful in teardown/ensure blocks to restore clean state between tests.
  #
  #   clear_devise_class_vars(User, :deny_old_passwords, :password_archiving_count)
  #
  def clear_devise_class_vars(klass, *var_names)
    var_names.each do |var|
      ivar = :"@#{var}"
      klass.remove_instance_variable(ivar) if klass.instance_variable_defined?(ivar)
    end
  end

  # Set password and confirmation on a user record, then save!
  #
  #   set_password(user, 'NewPassword1')
  #
  def set_password(user, password)
    user.password = password
    user.password_confirmation = password
    user.save!
  end
end
