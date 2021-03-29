# frozen_string_literal: true

MIGRATION_CLASS = ActiveRecord::Migration[Rails.version.to_f] if DEVISE_ORM == :active_record
