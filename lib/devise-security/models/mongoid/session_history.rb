# frozen_string_literal: true

# Tracks individual login sessions for +SessionTraceable+ users (Mongoid).
#
# Each document represents one authenticated session with metadata about
# the client and session activity. Used to enforce concurrent session
# limits and provide session audit history.
#
# == Fields
#
# - +token+ — unique session identifier, stored in the Warden session
# - +ip_address+ — IP address where the session was created (optional)
# - +user_agent+ — browser/client identifier (optional)
# - +last_accessed_at+ — when the session was last validated
# - +active+ — whether the session is still valid (+true+ by default)
#
# == Associations
#
# - +owner+ — polymorphic association to the devise model (e.g., +User+)
#
# @see Devise::Models::SessionTraceable
class SessionHistory
  include Devise::Models::Compatibility
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
