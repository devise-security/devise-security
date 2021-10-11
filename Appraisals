# frozen_string_literal: true

appraise 'rails-5.0' do
  gem 'railties', '~> 5.0.0'
  gem 'minitest-rails', '~> 5.0.0'

  group :active_record do
    gem 'sqlite3', '~> 1.3.0'
  end

  group :mongoid do
    gem 'database_cleaner-mongoid', '~> 2.0'
    gem 'mongoid', '~> 6.0'
  end
end

appraise 'rails-5.1' do
  gem 'railties', '~> 5.1.0'
  gem 'minitest-rails', '~> 5.1.0'

  group :mongoid do
    gem 'database_cleaner-mongoid', '~> 2.0'
    gem 'mongoid', '~> 6.0'
  end
end

appraise 'rails-5.2' do
  gem 'railties', '~> 5.2.0'
  gem 'minitest-rails', '~> 5.2.0'

  group :mongoid do
    gem 'database_cleaner-mongoid', '~> 2.0'
    gem 'mongoid', '~> 6.0'
  end
end

appraise 'rails-6.0' do
  gem 'railties', '~> 6.0.0'
  gem 'minitest-rails', '~> 6.0.0'

  group :mongoid do
    gem 'database_cleaner-mongoid', '~> 2.0'
    gem 'mongoid', '~> 7.0.5'
  end

  # net-smtp, net-imap and net-pop were removed from default gems in Ruby 3.1, but is used by the `mail` gem.
  # So we need to add them as dependencies until `mail` is fixed: https://github.com/mikel/mail/pull/1439
  # Taken from https://github.com/rails/rails/pull/42366
  gem "net-smtp", require: false
end

appraise 'rails-6.1' do
  gem 'railties', '~> 6.1.0'
  gem 'minitest-rails', '~> 6.1.0'

  group :mongoid do
    gem 'database_cleaner-mongoid', '~> 2.0'
    gem 'mongoid', '~> 7.0.5'
  end

  # net-smtp, net-imap and net-pop were removed from default gems in Ruby 3.1, but is used by the `mail` gem.
  # So we need to add them as dependencies until `mail` is fixed: https://github.com/mikel/mail/pull/1439
  # Taken from https://github.com/rails/rails/pull/42366
  gem "net-smtp", require: false
end
