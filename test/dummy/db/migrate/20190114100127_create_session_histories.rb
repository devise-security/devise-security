# frozen_string_literal: true

class CreateSessionHistories < MIGRATION_CLASS
  def up
    create_table :session_histories do |t|
      t.string :token, null: false, index: { unique: true }
      t.string :ip_address, index: true
      t.string :user_agent
      t.datetime :last_accessed_at, null: false, index: true
      t.boolean :active, default: true
      t.belongs_to :owner, polymorphic: true, null: false, index: true

      t.timestamps null: false
    end
  end

  def down
    drop_table :session_histories
  end
end
