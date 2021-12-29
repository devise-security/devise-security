# frozen_string_literal: true

module DeviseSecurity
  class AddBannedPasswords
    def initialize(file: '')
      @file = file
    end

    def add
      passwords = []
      File.foreach(@file) do |line|
        passwords << { password: line.chomp }
      end

      if Rails.gem_version >= Gem::Version.new('6.0')
        BannedPassword.insert_all(passwords)
      else
        passwords.each do |password|
          BannedPassword.create(password)
        end
      end
    end
  end
end