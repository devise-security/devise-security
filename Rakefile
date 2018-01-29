# frozen_string_literal: true

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'rubygems'
require 'bundler'
require 'rake/testtask'
require 'rdoc/task'
require 'devise-security/version'

desc 'Default: Run DeviseSecurity unit tests'
task default: :test

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.test_files = FileList['test/*test*.rb']
  t.verbose = true
  t.warning = false
end

Rake::RDocTask.new do |rdoc|
  version = DeviseSecurity::VERSION.dup

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "devise-security #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
