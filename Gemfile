# frozen_string_literal: true

source 'https://rubygems.org'
gemspec

# Oldest Rails version getting security patches is 5.2
gem 'railties', '~> 5.2.5'
gem 'minitest-rails', '~> 5.2.0'

group :active_record do
  gem 'sqlite3', '~> 1.3.0'
end

group :mongoid do
  gem 'mongoid'
end

# This dependency is here to support an older style of testing used with Rails
# 4.2. It can be dropped after we drop support for Rails 4.2 and we get rid of
# the older style tests.
group :test do
  gem 'rails-controller-testing', '<= 1.0.4' # update this when we drop Rails 4.2 support
end
