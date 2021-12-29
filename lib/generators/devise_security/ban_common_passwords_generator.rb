# frozen_string_literal: true

module DeviseSecurity
  module Generators
    class BanCommonPasswordsGenerator < Rails::Generators::Base
      desc 'Ban most common passwords'

      def ban_passwords
        BannedPassword.create(password: 'yo')
      end
    end
  end
end
