# -*- encoding: utf-8 -*-
# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('../lib', __FILE__)
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
    'Marco Scholl',
    'Alexander Dreher',
    'Nate Bird',
    'Dillon Welch',
    'Kevin Olbrich'
  ]
  s.post_install_message = 'WARNING: devise-security will drop support for Rails 4.2 in version 0.16.0'

  s.files         = Dir['README.md', 'LICENSE.txt', 'lib/**/*', 'app/**/*', 'config/**/*']
  s.test_files    = Dir['test/**/*']
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.3.0'

  s.add_runtime_dependency 'devise', '>= 4.3.0', '< 5.0'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'easy_captcha'
  s.add_development_dependency 'm'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'omniauth', '< 3.0.0'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'pry-rescue'
  s.add_development_dependency 'rails_email_validator'
  s.add_development_dependency 'rubocop', '~> 0.80.0' # NOTE: also update .codeclimate.yml and make sure it uses the same version
  s.add_development_dependency 'rubocop-rails'
  s.add_development_dependency 'simplecov-lcov'
  s.add_development_dependency 'solargraph'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'wwtd'
end
