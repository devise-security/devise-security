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

      puts passwords
    end
  end
end