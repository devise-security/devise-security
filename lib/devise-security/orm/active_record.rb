# frozen_string_literal: true

module DeviseSecurity
  module Orm
    # This module contains some helpers and handle schema (migrations):
    #
    #   create_table :accounts do |t|
    #     t.password_expirable
    #   end
    #
    module ActiveRecord
      module Schema
        include DeviseSecurity::Schema
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::Table.send :include, DeviseSecurity::Orm::ActiveRecord::Schema
ActiveRecord::ConnectionAdapters::TableDefinition.send :include, DeviseSecurity::Orm::ActiveRecord::Schema
