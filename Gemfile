# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

# Oldest Rails version getting security patches is 7.0
gem 'minitest-rails', '~> 7.0.0'
gem 'railties', '~> 7.0.0'

group :active_record do
  gem 'pg'
  gem 'sqlite3', '~> 1.4'
end

group :mongoid do
  gem 'mongoid', '~> 9.0'

  group :test do
    gem 'database_cleaner-mongoid', '~> 2.0'
  end
end

# This dependency is here to support an older style of testing that was used
# with Rails 4.2. It can be dropped after we get rid of the older style tests.
# Note that Devise itself still uses controller testing so we may need to retain
# this for consistency.
group :test do
  gem 'rails-controller-testing'
end

# Dependencies for Ruby 3.4 and up
gem 'bigdecimal', require: false
gem 'drb', require: false
