appraise 'rails-4.2' do
  gem 'rails', '~> 4.2.0'
  gem 'bundler', '< 2'
  group :mongoid do
    gem "mongoid", "~> 4.0"
  end
end

appraise 'rails-5.0' do
  gem 'rails', '~> 5.0.0'
  group :mongoid do
    gem "mongoid", "~> 6.0"
  end
end

appraise 'rails-5.1' do
  gem 'rails', '~> 5.1.0'
  group :mongoid do
    gem "mongoid", "~> 6.0"
  end
end

appraise 'rails-5.2' do
  gem 'rails', '~> 5.2.0'
  group :mongoid do
    gem "mongoid", "~> 6.0"
  end
end

appraise 'rails-6.0' do
  gem 'rails', '~> 6.0.0'
  group :mongoid do
    # mongoid has not released a Rails 6 compatible version
    gem "mongoid", "~> 7.0"
  end
end
