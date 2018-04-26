# frozen_string_literal: true

class AddWidget < MIGRATION_CLASS
  def change
    create_table :widgets do |t|
      t.string :name
      t.belongs_to :user
    end
  end
end
