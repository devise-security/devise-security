# frozen_string_literal: true

class CreateTables < MIGRATION_CLASS
  def self.up
    create_table :users do |t|
      t.string :username
      t.string :facebook_token
      t.string :unique_session_id, :limit => 20

      ## Database authenticatable
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      t.datetime :password_changed_at
      t.timestamps null: false
    end
    add_index :users, :password_changed_at
    add_index :users, :email

    create_table :secure_users do |t|
      t.string :email
      t.string :encrypted_password, null: false, default: ''
      t.timestamps null: false
    end

    create_table :old_passwords do |t|
      t.string :encrypted_password, :null => false
      t.string :password_salt
      t.string :password_archivable_type, :null => false
      t.integer :password_archivable_id, :null => false
      t.datetime :created_at
    end
    add_index :old_passwords, [:password_archivable_type, :password_archivable_id], :name => :index_password_archivable
  end

  def self.down
    drop_table :users
    drop_table :secure_users
    drop_table :old_passwords
  end
end
