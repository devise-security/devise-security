# frozen_string_literal: true

appraise 'rails-7.0' do
  gem 'railties', '~> 7.0.1' # Rails 7.0.0 and Ruby 3.1 are incompatible. See https://github.com/rails/rails/issues/43998 and https://github.com/rails/rails/pull/43951
  gem 'minitest-rails', '~> 7.0.0'
end

appraise 'rails-7.1' do
  gem 'railties', '~> 7.1.0'
  gem 'minitest-rails', '~> 7.1.0'
end

appraise 'rails-7.2' do
  gem 'railties', '~> 7.2.0'
  gem 'minitest-rails', '~> 7.2.0'
end

appraise 'rails-8.0' do
  gem 'railties', '~> 8.0.0'
  gem 'minitest-rails', '~> 8.0.0'

  group :active_record do
    gem 'sqlite3', '~> 2.1'
  end
end
