# frozen_string_literal: true

module DeviseSecurity
  class AddBannedPasswords
    def initialize(file: '')
      @file = file
    end

    def add
      if Rails.gem_version >= Gem::Version.new('6.0')
        passwords = []
        # TODO batch over certain size limit
        File.foreach(@file) do |line|
          passwords << { password: line.chomp }
        end

        if DEVISE_ORM == :mongoid
          BannedPassword.collection.insert_many(passwords)
        else
          BannedPassword.insert_all(passwords)
        end
      else
        File.foreach(@file) do |line|
          BannedPassword.create(password: line.chomp)
        end
      end
    end
  end
end
