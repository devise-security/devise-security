# frozen_string_literal: true
if DEVISE_ORM == :active_record
  class ApplicationUserRecord < ActiveRecord::Base
    self.table_name = 'users'
  end
else
  class ApplicationUserRecord
    include Mongoid::Document
    store_in collection: 'users'
  end
end
