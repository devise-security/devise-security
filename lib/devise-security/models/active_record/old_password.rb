# frozen_string_literal: true

class OldPassword < ApplicationRecord
  belongs_to :password_archivable, polymorphic: true
end
