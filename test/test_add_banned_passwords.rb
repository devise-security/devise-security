# frozen_string_literal: true

require 'test_helper'

require_relative '../lib/devise-security/add_banned_passwords'

class TestAddBannedPasswords < ActiveSupport::TestCase
  test 'it works' do
    # tempfile = Tempfile.new('dummy')
    # puts tempfile.path
    # tempfile.write('yo\nthere\nmeow')
    DeviseSecurity::AddBannedPasswords.new(file: "#{__dir__}/dummy.txt").add
  end
end