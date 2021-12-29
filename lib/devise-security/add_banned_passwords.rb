# frozen_string_literal: true

module DeviseSecurity
  class AddBannedPasswords
    def initialize(file: '')
      @file = file
    end

    def add
      puts @file
      File.foreach(@file) do |line|
        puts line
      end
    end
  end
end