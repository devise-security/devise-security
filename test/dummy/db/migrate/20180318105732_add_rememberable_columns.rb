# frozen_string_literal: true

class AddRememberableColumns < MIGRATION_CLASS
  def change
    add_column :users, :remember_created_at, :datetime
  end
end
