require 'test_helper'

class TestSanity < ActiveSupport::TestCase

  test 'can access ActiveRecord namespace' do
    # actually raises NameError: uninitialized constant Devise::Models::Compatibility::ActiveRecord::...
    assert_nothing_raised { User.new.some_method_calling_active_record }
  end
end
