# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

# Oldest Rails version getting security patches is 5.2
gem 'minitest-rails', '~> 5.2.0'
gem 'railties', '~> 5.2.4'

group :active_record do
  gem 'sqlite3'
end

group :mongoid do
  gem 'mongoid', '~> 6.0'
end

# This dependency is here to support an older style of testing used with Rails
# 4.2. It can be dropped after we drop support for Rails 4.2 and we get rid of
# the older style tests.
group :test do
  gem 'rails-controller-testing'
end
