# # frozen_string_literal: true
#
# class User < ApplicationRecord
#   include Mongoid::Document
#
#   field :username,                      type: String
#   field :facebook_token,                type: String
#   field :unique_session_id,             type: String
#
#   ## Database authenticatable
#   field :email,                         type: String, default: ""
#   validates_presence_of :email
#
#   field :encrypted_password,            type: String, default: ""
#   validates_presence_of :encrypted_password
#
#   field :password_changed_at,           type: Time
#   index({ password_changed_at: 1 }, {})
#   index({ email: 1 }, {})
#   include Mongoid::Timestamps
#
#   field :paranoid_verification_code,    type: String
#   field :paranoid_verification_at,      type: Time
#
#   field :paranoid_verification_attempt, type: Integer, default: 0
#
#   field :locked_at,                     type: Time
#   field :unlock_token,                  type: String
#
#   field :security_question_id,          type: Integer
#   field :security_question_answer,      type: String
#
#   field :expired_at,                    type: Time
#   field :last_activity_at,              type: Time
#
#   ## Recoverable
#   #field :reset_password_token, type: String
#   #field :reset_password_sent_at, type: Time
#
#   ## Rememberable
#   #field :remember_created_at, type: Time
#
#   ## Trackable
#   #field :sign_in_count, type: Integer, default: 0
#   #field :current_sign_in_at, type: Time
#   #field :last_sign_in_at, type: Time
#   #field :current_sign_in_ip, type: String
#   #field :last_sign_in_ip, type: String
#
#   ## Confirmable
#   field :confirmation_token,   type: String
#   field :confirmed_at,         type: Time
#   field :confirmation_sent_at, type: Time
#   field :unconfirmed_email,    type: String # Only if using reconfirmable
#
#   field :remember_created_at,  type: Time
#
#   ## Lockable
#   # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
#   # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
#   # field :locked_at,       type: Time
#
#   field :reset_password_token,  type: string
#   field :reset_password_sent_at,  type: Time
#
#   has_many :widgets
# end
#
# class SecureUsers < ApplicationRecord
#   include Mongoid::Document
#
#   field :email,                       type: String, default: ""
#   field :encrypted_password,          type: String, default: ""
#   validates_presence_of :encrypted_password
#   include Mongoid::Timestamps
# end
#
# class OldPassword < ApplicationRecord
#   include Mongoid::Document
#
#   field :encrypted_password,          type: String
#   field :password_salt,               type: String
#   field :password_archivable_type,    type: String
#   field :password_archivable_id,      type: Integer
#   include Mongoid::Timestamps::Created
#   index({password_archivable_type: 1, password_archivable_id: 1}, {name: :index_password_archivable})
# end
# #add_index :old_passwords, [:password_archivable_type, :password_archivable_id], :name => :index_password_archivable
#
# class Widgets < ApplicationRecord
#   field :name, type: String
#   belongs_to :user
# end
