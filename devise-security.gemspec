# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'devise-security/version'

Gem::Specification.new do |s|
  s.name        = 'devise-security'
  s.version     = DeviseSecurity::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['MIT']
  s.summary     = 'Security extension for devise'
  s.email       = 'natebird@gmail.com'
  s.homepage    = 'https://github.com/devise-security/devise-security'
  s.description = 'An enterprise security extension for devise.'
  s.authors     = [
    'Alexander Dreher',
    'Dillon Welch',
    'Kevin Olbrich',
    'Marco Scholl',
    'Nate Bird'
  ]
  s.metadata = {
    'bug_tracker_uri' => 'https://github.com/devise-security/devise-security/issues',
    'changelog_uri' => 'https://github.com/devise-security/devise-security/releases'
  }

  s.files         = Dir['README.md', 'LICENSE.txt', 'lib/**/*', 'app/**/*', 'config/**/*']
  s.test_files    = Dir['test/**/*']
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 3.1.0'

  s.add_runtime_dependency 'devise', '>= 4.8.1'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'byebug'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'easy_captcha'
  s.add_development_dependency 'i18n-tasks'
  s.add_development_dependency 'm'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'omniauth'
  s.add_development_dependency 'pry-rescue'
  s.add_development_dependency 'rails_email_validator'
  s.add_development_dependency 'rubocop'
  s.add_development_dependency 'rubocop-minitest'
  s.add_development_dependency 'rubocop-rails'
  s.add_development_dependency 'simplecov-lcov'
  s.add_development_dependency 'solargraph'
  s.add_development_dependency 'solargraph-arc'
  s.add_development_dependency 'mutex_m'
end
