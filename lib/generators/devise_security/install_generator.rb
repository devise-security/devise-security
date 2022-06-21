# frozen_string_literal: true

module DeviseSecurity
  module Generators
    # Generator for Rails to create or append to a Devise initializer.
    class InstallGenerator < Rails::Generators::Base
      LOCALES = %w[by cs de en es fa fr hi it ja nl pt ru tr uk zh_CN zh_TW].freeze

      source_root File.expand_path('../templates', __dir__)
      desc 'Install the devise security extension'

      def copy_initializer
        template('devise_security.rb', 'config/initializers/devise_security.rb')
      end

      def copy_locales
        LOCALES.each do |locale|
          copy_file(
            "../../../config/locales/#{locale}.yml",
            "config/locales/devise.security_extension.#{locale}.yml"
          )
        end
      end
    end
  end
end
