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
  end
end
