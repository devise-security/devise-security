# frozen_string_literal: true

class SessionHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  field :token, type: String
  field :ip_address, type: String
  field :user_agent, type: String
  field :last_accessed_at, type: DateTime
  field :active, type: Boolean, default: true

  belongs_to :owner, polymorphic: true, inverse_of: :session_histories

  with_options presence: true do
    validates :token, uniqueness: true
    validates :last_accessed_at, :owner
  end
end
