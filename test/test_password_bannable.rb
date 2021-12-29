# frozen_string_literal: true

require 'test_helper'

class TestPasswordArchivable < ActiveSupport::TestCase
  test "it works" do
    user = User.create email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1'
  end
end