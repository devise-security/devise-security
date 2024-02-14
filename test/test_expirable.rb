# frozen_string_literal: true

require 'test_helper'

class TestExpirable < ActiveSupport::TestCase
  test 'should have required_fields array' do
    assert_equal [:last_activity_at, :expired_at], Devise::Models::Expirable.required_fields(User)
  end
end
