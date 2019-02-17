# frozen_string_literal: true

if DEVISE_ORM == :active_record
  MIGRATION_CLASS =
    if Rails.gem_version >= Gem::Version.new('4.2')
      ActiveRecord::Migration[Rails.version.to_f]
    else
      ActiveRecord::Migration
    end
end
