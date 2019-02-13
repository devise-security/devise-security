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
    'Marco Scholl', 'Alexander Dreher', 'Nate Bird', 'Dillon Welch'
  ]

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.2.9'

  if RUBY_VERSION >= '2.4'
    s.add_runtime_dependency 'rails', '>= 4.1.0', '< 6.0'
  else
    s.add_runtime_dependency 'railties', '>= 4.1.0', '< 6.0'
  end
  s.add_runtime_dependency 'devise', '>= 4.2.0', '< 5.0'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'bundler', '>= 1.3.0', '< 2.0'
  s.add_development_dependency 'coveralls', '~> 0.8'
  s.add_development_dependency 'easy_captcha', '~> 0'
  s.add_development_dependency 'm'
  s.add_development_dependency 'minitest', '5.10.3' # see https://github.com/seattlerb/minitest/issues/730
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'pry-rescue'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rails_email_validator', '~> 0'
  s.add_development_dependency 'rubocop', '~> 0.54.0'
  unless defined? DEVISE_ORM
    DEVISE_ORM = (ENV["DEVISE_ORM"] || :active_record).to_sym
    DEVISE_ORM = :mongoid
  end
  if DEVISE_ORM == :mongoid
    s.add_development_dependency 'mongoid' #, '~> 7.0.1'
    puts '*' * 80
    puts DEVISE_ORM
    puts '*' * 80
    s.add_dependency("orm_adapter")
    #s.add_development_dependency 'mongoid-minitest'
    #s.add_development_dependency 'minitest-reporters'
    #s.add_development_dependency 'minitest-matchers'
  elsif DEVISE_ORM == :active_record
    s.add_development_dependency 'sqlite3', '~> 1.3', '>= 1.3.10'
  end
end
