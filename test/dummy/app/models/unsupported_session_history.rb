# frozen_string_literal: true

case DEVISE_ORM
when :active_record
  class UnsupportedSessionHistory < ApplicationRecord
    self.table_name = 'session_histories'
  end
when :mongoid
  class UnsupportedSessionHistory < ApplicationRecord
    include Mongoid::Timestamps
  end
end
