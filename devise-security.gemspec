# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift(File.expand_path('../lib', __FILE__))
require 'devise-security/version'

Gem::Specification.new do |s|
  s.name = 'devise-security'
  s.version     = DeviseSecurity::VERSION.dup
  s.platform    = Gem::Platform::RUBY
  s.licenses    = ['MIT']
  s.summary     = 'Security extension for devise'
  s.email       = 'natebird@gmail.com'
  s.homepage    = 'https://github.com/devise-security/devise-security'
  s.description = 'An enterprise security extension for devise, trying to meet industrial standard security demands for web applications.'
  s.authors     = ['Marco Scholl', 'Alexander Dreher', 'Nate Bird']

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- test/*`.split("\n")
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.1.0'

  if RUBY_VERSION >= '2.4'
    s.add_runtime_dependency 'rails', '>= 4.2.8', '< 6.0'
  else
    s.add_runtime_dependency 'railties', '>= 3.2.6', '< 6.0'
  end
  s.add_runtime_dependency 'devise', '>= 3.0.0', '< 5.0'
  s.add_development_dependency 'bundler', '>= 1.3.0', '< 2.0'
  s.add_development_dependency 'sqlite3', '~> 1.3', '>= 1.3.10'
  s.add_development_dependency 'rubocop', '~> 0'
  s.add_development_dependency 'minitest', '~> 5.0'
  s.add_development_dependency 'easy_captcha', '~> 0'
  s.add_development_dependency 'rails_email_validator', '~> 0'
  s.add_development_dependency 'coveralls', '~> 0.8'
end
