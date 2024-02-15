# frozen_string_literal: true

class TraceableUserWithLimit < ApplicationUserRecord
  devise :database_authenticatable,
         :confirmable,
         :expirable,
         :lockable,
         :paranoid_verification,
         :password_archivable,
         :password_expirable,
         :recoverable,
         :registerable,
         :rememberable,
         :secure_validatable,
         :security_questionable,
         :session_limitable,
         :session_traceable,
         :timeoutable,
         :trackable,
         :validatable

  if DEVISE_ORM == :mongoid
    require './test/dummy/app/models/mongoid/mappings'
    include ::Mongoid::Mappings
  end
end
