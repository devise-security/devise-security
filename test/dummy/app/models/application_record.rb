# frozen_string_literal: true

if DEVISE_ORM == :active_record
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
else
  class ApplicationRecord
    include Mongoid::Document
  end
end
