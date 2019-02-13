# frozen_string_literal: true

if DEVISE_ORM == :active_record
  MIGRATION_CLASS =
    if ActiveRecord::VERSION::MAJOR >= 5
      ActiveRecord::Migration[4.2]
    else
      ActiveRecord::Migration
    end
end
