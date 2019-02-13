# frozen_string_literal: true

if DEVISE_ORM == :active_record
  require 'active_record'
  class OldPassword < ActiveRecord::Base
    belongs_to :password_archivable, polymorphic: true
  end
elsif DEVISE_ORM == :mongoid
  class OldPassword
    include Mongoid::Document

    ## Database authenticatable
    field :encrypted_password, type: String
    validates_presence_of :encrypted_password
    field :password_salt, type: String

    field :password_archivable_type, type: String
    validates_presence_of :password_archivable_type

    field :password_archivable_id, type: String
    validates_presence_of :password_archivable_id
    index({ password_archivable_type: 1, password_archivable_id: 1 }, { name: :index_password_archivable })

    include Mongoid::Timestamps

    belongs_to :password_archivable, polymorphic: true
  end
end
