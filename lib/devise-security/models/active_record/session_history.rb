# frozen_string_literal: true

class SessionHistory < ApplicationRecord
  include Devise::Models::Compatibility

  belongs_to :owner, polymorphic: true, optional: false, inverse_of: :session_histories

  with_options presence: true do
    validates :token, uniqueness: true
    validates :last_accessed_at
  end
end
