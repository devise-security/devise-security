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

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.3.7'

  if RUBY_VERSION >= '2.4'
    s.add_runtime_dependency 'rails', '>= 4.2.0', '< 6.0'
  else
    s.add_runtime_dependency 'railties', '>= 4.2.0', '< 6.0'
  end
  s.add_runtime_dependency 'devise', '>= 4.2.0', '< 5.0'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'easy_captcha'
  s.add_development_dependency 'm'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'pry-rescue'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rails_email_validator'
  s.add_development_dependency 'rubocop', '~> 0.59.2'
  s.add_development_dependency 'sqlite3'
end
