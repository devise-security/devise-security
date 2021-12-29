# frozen_string_literal: true

class AddBannedPasswords < MIGRATION_CLASS
  def change
    create_table :banned_passwords do |t|
      t.string :password

      t.timestamps
    end
  end
end
