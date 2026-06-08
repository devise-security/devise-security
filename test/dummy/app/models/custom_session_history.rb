# frozen_string_literal: true

case DEVISE_ORM
when :active_record
  class CustomSessionHistory < ApplicationRecord
    include Devise::Models::Compatibility

    self.table_name = 'session_histories'

    belongs_to :owner, polymorphic: true
  end
when :mongoid
  class CustomSessionHistory < ApplicationRecord
    include Devise::Models::Compatibility
    include Mongoid::Timestamps

    field :token, type: String
    field :ip_address, type: String
    field :user_agent, type: String
    field :last_accessed_at, type: DateTime
    field :active, type: Boolean, default: true

    belongs_to :owner, polymorphic: true
  end
end
