# frozen_string_literal: true

require 'test_helper'

class TestCompatibility < ActiveSupport::TestCase
  test 'can access ActiveRecord namespace' do
    skip unless DEVISE_ORM == :active_record
    assert_nothing_raised { User.new.some_method_calling_active_record }
  end

  test 'can access Mongoid namespace' do
    skip unless DEVISE_ORM == :mongoid
    assert_nothing_raised { User.new.some_method_calling_mongoid }
  end
end
