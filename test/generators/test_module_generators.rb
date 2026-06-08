# frozen_string_literal: true

require 'test_helper'

if DEVISE_ORM == :active_record
  require 'generators/devise_security/module_migration_generator'

  # Tests for per-module migration generators (issue #295).
  #
  # REQUIREMENTS:
  # - Each module that needs DB changes has its own generator
  # - Generators are invoked as: rails generate devise_security:<module> [MODEL]
  # - MODEL defaults to 'user' (table_name: 'users')
  # - "Add columns" generators create add_<module>_to_<table> migrations
  # - "Create table" generators create create_<table> migrations
  # - All generators are idempotent (safe to run twice)
  # - Templates use correct column types (inet for PG, string otherwise)

  class TestSessionLimitableGenerator < Rails::Generators::TestCase
    tests DeviseSecurity::Generators::SessionLimitableGenerator
    destination File.expand_path('../dummy/tmp', __dir__)
    setup :prepare_destination

    test 'creates migration for default user model' do
      run_generator
      assert_migration 'db/migrate/add_session_limitable_to_users.rb' do |migration|
        assert_match(/add_column :users, :unique_session_id, :string/, migration)
      end
    end

    test 'creates migration for custom model' do
      run_generator ['admin']
      assert_migration 'db/migrate/add_session_limitable_to_admins.rb' do |migration|
        assert_match(/add_column :admins, :unique_session_id, :string/, migration)
      end
    end

    test 'is idempotent' do
      run_generator
      assert_nothing_raised { run_generator }
    end
  end

  class TestSessionTraceableGenerator < Rails::Generators::TestCase
    tests DeviseSecurity::Generators::SessionTraceableGenerator
    destination File.expand_path('../dummy/tmp', __dir__)
    setup :prepare_destination

    test 'creates session_histories table migration' do
      run_generator
      assert_migration 'db/migrate/create_session_histories.rb' do |migration|
        assert_match(/create_table :session_histories/, migration)
        assert_match(/t.string :token, null: false/, migration)
        assert_match(/t\.(string|inet) :ip_address/, migration)
        assert_match(/t.string :user_agent/, migration)
        assert_match(/t.datetime :last_accessed_at, null: false/, migration)
        assert_match(/t.boolean :active, default: true, null: false/, migration)
        assert_match(/t.belongs_to :owner, polymorphic: true/, migration)
      end
    end

    test 'is idempotent' do
      run_generator
      assert_nothing_raised { run_generator }
    end
  end

  class TestPasswordExpirableGenerator < Rails::Generators::TestCase
    tests DeviseSecurity::Generators::PasswordExpirableGenerator
    destination File.expand_path('../dummy/tmp', __dir__)
    setup :prepare_destination

    test 'creates migration with password_changed_at column' do
      run_generator
      assert_migration 'db/migrate/add_password_expirable_to_users.rb' do |migration|
        assert_match(/add_column :users, :password_changed_at, :datetime/, migration)
        assert_match(/add_index :users, :password_changed_at/, migration)
      end
    end

    test 'creates migration for custom model' do
      run_generator ['member']
      assert_migration 'db/migrate/add_password_expirable_to_members.rb' do |migration|
        assert_match(/add_column :members, :password_changed_at, :datetime/, migration)
      end
    end
  end

  class TestExpirableGenerator < Rails::Generators::TestCase
    tests DeviseSecurity::Generators::ExpirableGenerator
    destination File.expand_path('../dummy/tmp', __dir__)
    setup :prepare_destination

    test 'creates migration with expirable columns' do
      run_generator
      assert_migration 'db/migrate/add_expirable_to_users.rb' do |migration|
        assert_match(/add_column :users, :last_activity_at, :datetime/, migration)
        assert_match(/add_column :users, :expired_at, :datetime/, migration)
        assert_match(/add_index :users, :last_activity_at/, migration)
        assert_match(/add_index :users, :expired_at/, migration)
      end
    end
  end

  class TestParanoidVerificationGenerator < Rails::Generators::TestCase
    tests DeviseSecurity::Generators::ParanoidVerificationGenerator
    destination File.expand_path('../dummy/tmp', __dir__)
    setup :prepare_destination

    test 'creates migration with paranoid verification columns' do
      run_generator
      assert_migration 'db/migrate/add_paranoid_verification_to_users.rb' do |migration|
        assert_match(/add_column :users, :paranoid_verification_code, :string/, migration)
        assert_match(/add_column :users, :paranoid_verification_attempt, :integer, default: 0/, migration)
        assert_match(/add_column :users, :paranoid_verified_at, :datetime/, migration)
      end
    end
  end

  class TestPasswordArchivableGenerator < Rails::Generators::TestCase
    tests DeviseSecurity::Generators::PasswordArchivableGenerator
    destination File.expand_path('../dummy/tmp', __dir__)
    setup :prepare_destination

    test 'creates old_passwords table migration' do
      run_generator
      assert_migration 'db/migrate/create_old_passwords.rb' do |migration|
        assert_match(/create_table :old_passwords/, migration)
        assert_match(/t.string :encrypted_password, null: false/, migration)
        assert_match(/t.string :password_salt/, migration)
        assert_match(/t.string :password_archivable_type, null: false/, migration)
        assert_match(/t.integer :password_archivable_id, null: false/, migration)
      end
    end

    test 'is idempotent' do
      run_generator
      assert_nothing_raised { run_generator }
    end
  end

  class TestSecurityQuestionableGenerator < Rails::Generators::TestCase
    tests DeviseSecurity::Generators::SecurityQuestionableGenerator
    destination File.expand_path('../dummy/tmp', __dir__)
    setup :prepare_destination

    test 'creates migration with user columns' do
      run_generator
      assert_migration 'db/migrate/add_security_questionable_to_users.rb' do |migration|
        assert_match(/add_column :users, :security_question_id, :integer/, migration)
        assert_match(/add_column :users, :security_question_answer, :string/, migration)
      end
    end

    test 'creates security_questions table migration' do
      run_generator
      assert_migration 'db/migrate/create_security_questions.rb' do |migration|
        assert_match(/create_table :security_questions/, migration)
        assert_match(/t.string :locale, null: false/, migration)
        assert_match(/t.string :name, null: false/, migration)
      end
    end
  end
end
