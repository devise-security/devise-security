# frozen_string_literal: true

module DeviseSecurity
  class AddBannedPasswords
    def initialize(file: '')
      @file = file
      puts 'hi'
    end

    def add
      File.foreach(file) do |line|
      end
    end
  end
end