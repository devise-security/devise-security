# frozen_string_literal: true

require 'test_helper'

class TestPasswordArchivable < ActiveSupport::TestCase
  test 'user is valid if password is not banned' do
    BannedPassword.create(password: 'Password2')
    user = User.new(email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1')

    assert(user.valid?)
  end

  test 'user is invalid if password is banned' do
    BannedPassword.create(password: 'Password1')
    user = User.new(email: 'bob@microsoft.com', password: 'Password1', password_confirmation: 'Password1')

    user.valid?
    assert_equal(user.errors.messages, { password: ['is banned.'] })
  end
end
