# frozen_string_literal: true

class AddExpireableColumns < MIGRATION_CLASS
  def change
    add_column :users, :expired_at, :datetime
    add_column :users, :last_activity_at, :datetime
  end
end
