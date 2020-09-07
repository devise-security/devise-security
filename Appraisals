# frozen_string_literal: true

if RUBY_VERSION < '2.7'
  appraise 'rails-4.2' do
    gem 'rails', '~> 4.2.0'
    gem 'minitest-rails', '~> 2.0'
    gem 'bundler', '< 2'

    group :active_record do
      gem 'sqlite3', '~> 1.3.0'
    end

    group :mongoid do
      gem 'mongoid', '~> 4.0'
    end
  end
end

appraise 'rails-5.0' do
  gem 'rails', '~> 5.0.0'
  gem 'minitest-rails', '~> 5.0.0'

  group :active_record do
    gem 'sqlite3', '~> 1.3.0'
  end

  group :test do
    gem 'rails-controller-testing', '1.0.4'
  end

  group :mongoid do
    gem 'mongoid', '~> 6.0'
  end
end

appraise 'rails-5.1' do
  gem 'rails', '~> 5.1.0'
  gem 'minitest-rails', '~> 5.1.0'

  group :active_record do
    gem 'sqlite3', '~> 1.3.0'
  end

  group :test do
    gem 'rails-controller-testing', '1.0.4'
  end

  group :mongoid do
    gem 'mongoid', '~> 6.0'
  end
end

appraise 'rails-5.2' do
  gem 'rails', '~> 5.2.0'
  gem 'minitest-rails', '~> 5.2.0'

  group :active_record do
    gem 'sqlite3', '~> 1.3.0'
  end

  group :test do
    gem 'rails-controller-testing', '1.0.4'
  end

  group :mongoid do
    gem 'mongoid', '~> 6.0'
  end
end

appraise 'rails-6.0' do
  gem 'rails', '~> 6.0.0'
  gem 'minitest-rails', '~> 6.0.0'

  group :active_record do
    gem 'sqlite3'
  end

  group :test do
    gem 'rails-controller-testing', '1.0.4'
  end

  group :mongoid do
    gem 'mongoid', '~> 7.0.5'
  end
end
