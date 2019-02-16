# frozen_string_literal: true

if DEVISE_ORM == :active_record
  MIGRATION_CLASS =
    if Rails.gem_version >= Gem::Version.new('4.2')
      ActiveRecord::Migration[ActiveRecord::Migration.current_version]
    else
      ActiveRecord::Migration
    end
end
