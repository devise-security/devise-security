# frozen_string_literal: true

require 'active_record'
require 'active_support/core_ext/integer'
require 'active_support/ordered_hash'
require 'active_support/concern'
require 'devise'

module Devise
  # Number of seconds that passwords are valid (e.g 3.months)
  # Disable pasword expiration with +false+
  # Expire only on demand with +true+
  mattr_accessor :expire_password_after
  @@expire_password_after = 3.months

  # Validate password strength
  mattr_accessor :password_complexity
  @@password_complexity = { digit: 1, lower: 1, symbol: 1, upper: 1 }

  # Number of old passwords in archive
  mattr_accessor :password_archiving_count
  @@password_archiving_count = 5

  # Deny old password (true, false, count)
  mattr_accessor :deny_old_passwords
  @@deny_old_passwords = true

  # enable email validation for :secure_validatable. (true, false, validation_options)
  # dependency: need an email validator, see https://github.com/devise-security/devise-security/blob/master/README.md#e-mail-validation
  mattr_accessor :email_validation
  @@email_validation = true

  # captcha integration for recover form
  mattr_accessor :captcha_for_recover
  @@captcha_for_recover = false

  # captcha integration for sign up form
  mattr_accessor :captcha_for_sign_up
  @@captcha_for_sign_up = false

  # captcha integration for sign in form
  mattr_accessor :captcha_for_sign_in
  @@captcha_for_sign_in = false

  # captcha integration for unlock form
  mattr_accessor :captcha_for_unlock
  @@captcha_for_unlock = false

  # security_question integration for recover form
  # this automatically enables captchas (captcha_for_recover, as fallback)
  mattr_accessor :security_question_for_recover
  @@security_question_for_recover = false

  # security_question integration for unlock form
  # this automatically enables captchas (captcha_for_unlock, as fallback)
  mattr_accessor :security_question_for_unlock
  @@security_question_for_unlock = false

  # security_question integration for confirmation form
  # this automatically enables captchas (captcha_for_confirmation, as fallback)
  mattr_accessor :security_question_for_confirmation
  @@security_question_for_confirmation = false

  # captcha integration for confirmation form
  mattr_accessor :captcha_for_confirmation
  @@captcha_for_confirmation = false

  # captcha integration for confirmation form
  mattr_accessor :verification_code_generator
  @@verification_code_generator = -> { SecureRandom.hex[0..4] }

  # Time period for account expiry from last_activity_at
  mattr_accessor :expire_after
  @@expire_after = 90.days
  mattr_accessor :delete_expired_after
  @@delete_expired_after = 90.days

  # paranoid_verification will regenerate verifacation code after faild attempt
  mattr_accessor :paranoid_code_regenerate_after_attempt
  @@paranoid_code_regenerate_after_attempt = 10
end

# an security extension for devise
module DeviseSecurity
  autoload :Schema, 'devise-security/schema'
  autoload :Patches, 'devise-security/patches'

  module Controllers
    autoload :Helpers, 'devise-security/controllers/helpers'
  end
end

# modules
Devise.add_module :password_expirable, controller: :password_expirable, model: 'devise-security/models/password_expirable', route: :password_expired
Devise.add_module :secure_validatable, model: 'devise-security/models/secure_validatable'
Devise.add_module :password_archivable, model: 'devise-security/models/password_archivable'
Devise.add_module :session_limitable, model: 'devise-security/models/session_limitable'
Devise.add_module :session_non_transferable, model: 'devise-security/models/session_non_transferable'
Devise.add_module :expirable, model: 'devise-security/models/expirable'
Devise.add_module :security_questionable, model: 'devise-security/models/security_questionable'
Devise.add_module :paranoid_verification, controller: :paranoid_verification_code, model: 'devise-security/models/paranoid_verification', route: :verification_code

# requires
require 'devise-security/routes'
require 'devise-security/rails'
require 'devise-security/orm/active_record'
require 'devise-security/models/old_password'
require 'devise-security/models/database_authenticatable_patch'
require 'devise-security/models/paranoid_verification'
