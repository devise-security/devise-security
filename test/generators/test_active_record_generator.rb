# frozen_string_literal: true

require 'test_helper'

if DEVISE_ORM == :active_record
  require 'generators/active_record/devise_security_generator'

  class TestActiveRecordGenerator < Rails::Generators::TestCase
    tests ActiveRecord::Generators::DeviseSecurityGenerator
    destination File.expand_path('../dummy/tmp', __dir__)
    setup :prepare_destination

    test 'all files are properly created with migration syntax' do
      assert_nothing_raised { run_generator }
    end

    test 'create session_histories migration' do
      run_generator

      assert_migration 'db/migrate/create_session_histories.rb' do |migration|
        assert_instance_method :up, migration do |up|
          assert_match(/t.(string|inet) :ip_address/, up)
        end
      end
    end
  end
end
