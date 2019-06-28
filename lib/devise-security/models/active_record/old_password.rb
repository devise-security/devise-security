# frozen_string_literal: true

class OldPassword < ActiveRecord::Base
  belongs_to :password_archivable, polymorphic: true
end
