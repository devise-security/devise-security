# frozen_string_literal: true

class AddRecoverableColumns < MIGRATION_CLASS
  def change
    add_column :users, :reset_password_token, :string
    add_column :users, :reset_password_sent_at, :datetime
  end
end
