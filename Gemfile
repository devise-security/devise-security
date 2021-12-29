# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

# Oldest Rails version getting security patches is 5.2
gem 'minitest-rails', '~> 5.2.0'
gem 'railties', '~> 5.2.6'

group :active_record do
  gem 'sqlite3'
end

group :mongoid do
  gem 'mongoid', '~> 7.3'

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
