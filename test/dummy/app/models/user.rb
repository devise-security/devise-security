# frozen_string_literal: true

class User < ApplicationRecord

  devise :database_authenticatable,
         :confirmable,
         :expirable,
         :lockable,
         :omniauthable,
         :paranoid_verification,
         :password_archivable,
         :password_expirable,
         :recoverable,
         :registerable,
         :rememberable,
         :secure_validatable,
         :security_questionable,
         :session_limitable,
         :timeoutable,
         :trackable,
         :validatable

  has_many :widgets

  if DEVISE_ORM == :mongoid
    require './test/dummy/app/models/mongoid/mappings'
    include ::Mongoid::Mappings

    def some_method_calling_mongoid
      Mongoid.logger
    end
  elsif DEVISE_ORM == :active_record
    def some_method_calling_active_record
      ActiveRecord::Base.transaction {}
    end
  end
end
