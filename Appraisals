# frozen_string_literal: true

appraise 'rails-5.2' do
  gem 'railties', '~> 5.2.0'
  gem 'minitest-rails', '~> 5.2.0'
end

appraise 'rails-6.0' do
  gem 'railties', '~> 6.0.0'
  gem 'minitest-rails', '~> 6.0.0'

  # net-smtp, net-imap and net-pop were removed from default gems in Ruby 3.1, but is used by the `mail` gem.
  # So we need to add them as dependencies until `mail` is fixed: https://github.com/mikel/mail/pull/1439
  # Taken from https://github.com/rails/rails/pull/42366
  gem 'net-smtp', require: false
end

appraise 'rails-6.1' do
  gem 'railties', '~> 6.1.0'
  gem 'minitest-rails', '~> 6.1.0'

  # net-smtp, net-imap and net-pop were removed from default gems in Ruby 3.1, but is used by the `mail` gem.
  # So we need to add them as dependencies until `mail` is fixed: https://github.com/mikel/mail/pull/1439
  # Taken from https://github.com/rails/rails/pull/42366
  gem 'net-smtp', require: false
end

appraise 'rails-7.0' do
  gem 'railties', '~> 7.0.1' # Rails 7.0.0 and Ruby 3.1 are incompatible. See https://github.com/rails/rails/issues/43998 and https://github.com/rails/rails/pull/43951
  gem 'devise', '>= 4.8.1' # devise introduced Rails 7 support
  gem 'minitest-rails', '~> 7.0.0'

  # net-smtp, net-imap and net-pop were removed from default gems in Ruby 3.1, but is used by the `mail` gem.
  # So we need to add them as dependencies until `mail` is fixed: https://github.com/mikel/mail/pull/1439
  # Taken from https://github.com/rails/rails/pull/42366
  gem 'net-smtp', require: false
end