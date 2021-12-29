# frozen_string_literal: true

require 'test_helper'

require_relative '../lib/devise-security/add_banned_passwords'

class TestAddBannedPasswords < ActiveSupport::TestCase
  test 'it works' do
    DeviseSecurity::AddBannedPasswords.new(file: "#{__dir__}/dummy.txt").add

    # TODO password uniqueness
    assert_equal(BannedPassword.count, 2)
    assert(BannedPassword.where(password: 'cats').exists?)
    assert(BannedPassword.where(password: 'meow').exists?)
  end
end
