# frozen_string_literal: true

if DEVISE_ORM == :active_record
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

    # if DEVISE_ORM == :mongoid
    #   #include Shim
    #   #include SharedUserWithPasswordVerification
    #   #include SharedSecurityQuestionsFields
    #
    #   field :password_changed_at, type: Time
    #   index({ password_changed_at: 1 }, {})
    #
    #   field :paranoid_verification_code, type: String
    #   field :paranoid_verified_at, type: Time
    #   field :paranoid_verification_attempt, type: Integer, default: 0
    #
    #   field :username, type: String
    #   field :facebook_token, type: String
    #
    #   ## Database authenticatable
    #   field :email,              type: String, default: ""
    #   field :encrypted_password, type: String, default: ""
    #
    #   ## Recoverable
    #   field :reset_password_token,   type: String
    #   field :reset_password_sent_at, type: Time
    #
    #   ## Rememberable
    #   field :remember_created_at, type: Time
    #
    #   ## Trackable
    #   field :sign_in_count,      type: Integer, default: 0
    #   field :current_sign_in_at, type: Time
    #   field :last_sign_in_at,    type: Time
    #   field :current_sign_in_ip, type: String
    #   field :last_sign_in_ip,    type: String
    #
    #   ## Confirmable
    #   field :confirmation_token,   type: String
    #   field :confirmed_at,         type: Time
    #   field :confirmation_sent_at, type: Time
    #   # field :unconfirmed_email,    type: String # Only if using reconfirmable
    #
    #   ## Lockable
    #   field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
    #   field :unlock_token,    type: String # Only if unlock strategy is :email or :both
    #   field :locked_at,       type: Time
    # end
  end
elsif DEVISE_ORM == :mongoid
  require './test/dummy/app/models/mongoid/mappings'
  class User
    include Mongoid::Document

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

    include Mongoid::Mappings
  end
end