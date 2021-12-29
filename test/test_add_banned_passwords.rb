# frozen_string_literal: true

require 'test_helper'

require_relative '../lib/devise-security/add_banned_passwords'

class TestAddBannedPasswords < ActiveSupport::TestCase
  test 'it works' do
    DeviseSecurity::AddBannedPasswords.new.add
  end
end