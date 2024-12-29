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

  case DEVISE_ORM
  when :mongoid
    require './test/dummy/app/models/mongoid/mappings'
    include ::Mongoid::Mappings

    def some_method_calling_mongoid
      Mongoid.logger
    end
  when :active_record
    def some_method_calling_active_record
      ActiveRecord::Base.transaction { break; }
    end
  end

  # Starting in Rails 8.0, sending devise notification emails in test can fail because the Devise mappings for classes
  # haven't yet been loaded and the mailer needs them to send emails. These tests don't actually need the emails to be
  # sent, so we can just redefine this method to do nothing.
  def send_devise_notification(...)
    # no-op
  end
end
