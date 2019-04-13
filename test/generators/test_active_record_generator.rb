# frozen_string_literal: true

require 'test_helper'

if DEVISE_ORM == :active_record
  require 'generators/active_record/devise_security_generator'

  class TestActiveRecordGenerator < Rails::Generators::TestCase
    tests ActiveRecord::Generators::DeviseSecurityGenerator
    destination File.expand_path('tmp', __dir__)
    setup :prepare_destination

    test 'all files are properly created with migration syntax' do
      run_generator %w[SessionHistory]
      assert_migration 'db/migrate/create_session_histories.rb', /def up/
    end

    test 'all files are properly deleted' do
      run_generator %w[SessionHistory]
      assert_migration 'db/migrate/create_session_histories.rb'
      run_generator %w[SessionHistory], behavior: :revoke
      assert_no_migration 'db/migrate/create_session_histories.rb'
    end
  end
end
