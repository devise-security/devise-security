# frozen_string_literal: true

require 'test_helper'
class TestPasswordArchivable < ActiveSupport::TestCase
  test 'user is valid if password is not banned' do
    BannedPassword.create(password: 'Password2')
    user = User.create(email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1')

    assert(user.valid?)
  end
end