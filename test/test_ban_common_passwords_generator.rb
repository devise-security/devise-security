# frozen_string_literal: true

require 'test_helper'
require 'rails/generators/test_case'
require 'generators/devise_security/ban_common_passwords_generator'

class TestBanCommonPasswordsGenerator < Rails::Generators::TestCase
  tests DeviseSecurity::Generators::BanCommonPasswordsGenerator
  destination File.expand_path('tmp', __dir__)
  # setup :prepare_destination

  test 'pls' do
    run_generator
  end
end
