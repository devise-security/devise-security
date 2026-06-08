# frozen_string_literal: true

DEVISE_ORM = ENV.fetch('DEVISE_ORM', 'active_record').to_sym unless defined?(DEVISE_ORM)

require DEVISE_ORM.to_s if DEVISE_ORM.in? %i[active_record mongoid]
require 'active_support/core_ext/integer'
require 'active_support/ordered_hash'
require 'active_support/concern'
require 'devise'

module Devise
  # @!attribute [rw] expire_password_after
  #   Duration after which passwords expire (e.g. +3.months+).
  #   Set to +false+ to disable expiration, or +true+ to expire only on demand.
  #   @return [ActiveSupport::Duration, Boolean] default: +3.months+
  #   @see Devise::Models::PasswordExpirable
  mattr_accessor :expire_password_after
  @@expire_password_after = 3.months

  # @!attribute [rw] password_complexity
  #   Required character counts per category for password validation.
  #   Keys: +:digit+, +:lower+, +:symbol+, +:upper+. Values: minimum count.
  #   @return [Hash{Symbol => Integer}] default: +{ digit: 1, lower: 1, symbol: 1, upper: 1 }+
  #   @see Devise::Models::SecureValidatable
  mattr_accessor :password_complexity
  @@password_complexity = { digit: 1, lower: 1, symbol: 1, upper: 1 }

  # @!attribute [rw] password_complexity_validator
  #   Class (or string path) used to validate password complexity.
  #   @return [Class, String] default: +"devise_security/password_complexity_validator"+
  #   @see Devise::Models::SecureValidatable
  mattr_accessor :password_complexity_validator
  @@password_complexity_validator = 'devise_security/password_complexity_validator'

  # @!attribute [rw] password_archiving_count
  #   Maximum number of old passwords stored in the archive.
  #   @return [Integer] default: +5+
  #   @see Devise::Models::PasswordArchivable
  mattr_accessor :password_archiving_count
  @@password_archiving_count = 5

  # @!attribute [rw] deny_old_passwords
  #   Whether to deny reuse of old passwords. +true+ denies all archived
  #   passwords, +false+ disables the check, an +Integer+ denies that many
  #   most-recent passwords.
  #   @return [Boolean, Integer] default: +true+
  #   @see Devise::Models::PasswordArchivable
  mattr_accessor :deny_old_passwords
  @@deny_old_passwords = true

  # @!attribute [rw] deny_old_passwords_period
  #   Time window for denying password reuse (e.g. +3.months+).
  #   When set, passwords used within this period are denied regardless of count.
  #   Takes precedence over {deny_old_passwords} count when both are set.
  #   +nil+ disables time-based checking (count-based only).
  #   @return [ActiveSupport::Duration, nil] default: +nil+
  #   @see Devise::Models::PasswordArchivable
  mattr_accessor :deny_old_passwords_period
  @@deny_old_passwords_period = nil

  # @!attribute [rw] email_validation
  #   Enable email format validation for +:secure_validatable+.
  #   +true+ enables, +false+ disables, or pass a Hash of validation options.
  #   Requires an email validator gem (e.g. +email_validator+).
  #   @return [Boolean, Hash] default: +true+
  #   @see Devise::Models::SecureValidatable
  mattr_accessor :email_validation
  @@email_validation = true

  # @!attribute [rw] captcha_for_recover
  #   Enable captcha on the password recovery form.
  #   @return [Boolean] default: +false+
  #   @see DeviseSecurity::Patches
  mattr_accessor :captcha_for_recover
  @@captcha_for_recover = false

  # @!attribute [rw] captcha_for_sign_up
  #   Enable captcha on the sign-up form.
  #   @return [Boolean] default: +false+
  #   @see DeviseSecurity::Patches
  mattr_accessor :captcha_for_sign_up
  @@captcha_for_sign_up = false

  # @!attribute [rw] captcha_for_sign_in
  #   Enable captcha on the sign-in form.
  #   @return [Boolean] default: +false+
  #   @see DeviseSecurity::Patches
  mattr_accessor :captcha_for_sign_in
  @@captcha_for_sign_in = false

  # @!attribute [rw] captcha_for_unlock
  #   Enable captcha on the account unlock form.
  #   @return [Boolean] default: +false+
  #   @see DeviseSecurity::Patches
  mattr_accessor :captcha_for_unlock
  @@captcha_for_unlock = false

  # @!attribute [rw] security_question_for_recover
  #   Enable security question on the password recovery form.
  #   Also enables captcha as a fallback (+captcha_for_recover+).
  #   @return [Boolean] default: +false+
  #   @see Devise::Models::SecurityQuestionable
  mattr_accessor :security_question_for_recover
  @@security_question_for_recover = false

  # @!attribute [rw] security_question_for_unlock
  #   Enable security question on the account unlock form.
  #   Also enables captcha as a fallback (+captcha_for_unlock+).
  #   @return [Boolean] default: +false+
  #   @see Devise::Models::SecurityQuestionable
  mattr_accessor :security_question_for_unlock
  @@security_question_for_unlock = false

  # @!attribute [rw] security_question_for_confirmation
  #   Enable security question on the confirmation form.
  #   Also enables captcha as a fallback (+captcha_for_confirmation+).
  #   @return [Boolean] default: +false+
  #   @see Devise::Models::SecurityQuestionable
  mattr_accessor :security_question_for_confirmation
  @@security_question_for_confirmation = false

  # @!attribute [rw] captcha_for_confirmation
  #   Enable captcha on the confirmation form.
  #   @return [Boolean] default: +false+
  #   @see DeviseSecurity::Patches
  mattr_accessor :captcha_for_confirmation
  @@captcha_for_confirmation = false

  # @!attribute [rw] verification_code_generator
  #   Lambda that generates paranoid verification codes.
  #   @return [Proc] default: +-> { SecureRandom.hex[0..4] }+
  #   @see Devise::Models::ParanoidVerification
  mattr_accessor :verification_code_generator
  @@verification_code_generator = -> { SecureRandom.hex[0..4] }

  # @!attribute [rw] expire_after
  #   Duration of inactivity after which an account expires.
  #   Measured from +last_activity_at+.
  #   @return [ActiveSupport::Duration] default: +90.days+
  #   @see Devise::Models::Expirable
  mattr_accessor :expire_after
  @@expire_after = 90.days

  # @!attribute [rw] delete_expired_after
  #   Duration after expiry at which expired accounts may be deleted.
  #   @return [ActiveSupport::Duration] default: +90.days+
  #   @see Devise::Models::Expirable
  mattr_accessor :delete_expired_after
  @@delete_expired_after = 90.days

  # @!attribute [rw] last_activity_update_interval
  #   Minimum interval between +last_activity_at+ DB writes.
  #   Set to a duration (e.g. +5.minutes+) to throttle writes.
  #   +nil+ or +0+ disables throttling (every request writes).
  #   @return [ActiveSupport::Duration, nil] default: +nil+
  #   @see Devise::Models::Expirable
  mattr_accessor :last_activity_update_interval
  @@last_activity_update_interval = nil

  # @!attribute [rw] paranoid_code_regenerate_after_attempt
  #   Number of failed verification attempts before the code is regenerated.
  #   @return [Integer] default: +10+
  #   @see Devise::Models::ParanoidVerification
  mattr_accessor :paranoid_code_regenerate_after_attempt
  @@paranoid_code_regenerate_after_attempt = 10

  # @!attribute [rw] allow_passwords_equal_to_email
  #   When +false+, passwords matching the user's email (case-insensitive)
  #   are rejected.
  #   @return [Boolean] default: +false+
  #   @see Devise::Models::SecureValidatable
  mattr_accessor :allow_passwords_equal_to_email
  @@allow_passwords_equal_to_email = false

  # @!attribute [rw] session_history_class
  #   Class name for session history records.
  #   @return [String] default: +"SessionHistory"+
  #   @see Devise::Models::SessionTraceable
  mattr_accessor :session_history_class
  @@session_history_class = 'SessionHistory'

  # @!attribute [rw] session_ip_verification
  #   When +true+, session tokens are bound to the client IP address.
  #   A request from a different IP invalidates the session.
  #   @return [Boolean] default: +true+
  #   @see Devise::Models::SessionTraceable
  mattr_accessor :session_ip_verification
  @@session_ip_verification = true

  # @!attribute [rw] max_active_sessions
  #   Maximum number of concurrent active sessions per user.
  #   Oldest sessions are expired when the limit is exceeded.
  #   @return [Integer] default: +1+
  #   @see Devise::Models::SessionLimitable
  mattr_accessor :max_active_sessions
  @@max_active_sessions = 1

  # @!attribute [rw] reject_sessions
  #   When +true+, new login attempts are rejected (instead of expiring old
  #   sessions) once {max_active_sessions} is reached.
  #   @return [Boolean] default: +false+
  #   @see Devise::Models::SessionLimitable
  mattr_accessor :reject_sessions
  @@reject_sessions = false

  # @!attribute [rw] require_password_on_email_change
  #   Require current password when changing email address.
  #   Accepts +true+, +false+, or a +Proc+ for dynamic resolution.
  #   @return [Boolean, Proc] default: +false+
  #   @see Devise::Models::SecureValidatable
  mattr_accessor :require_password_on_email_change
  @@require_password_on_email_change = false
end

# a security extension for devise
module DeviseSecurity
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
Devise.add_module :session_traceable, model: 'devise-security/models/session_traceable'
Devise.add_module :expirable, model: 'devise-security/models/expirable'
Devise.add_module :security_questionable, model: 'devise-security/models/security_questionable'
Devise.add_module :paranoid_verification, controller: :paranoid_verification_code, model: 'devise-security/models/paranoid_verification', route: :verification_code

# requires
require 'devise-security/routes'
require 'devise-security/rails'
require "devise-security/orm/#{DEVISE_ORM}" if DEVISE_ORM == :mongoid
require 'devise-security/models/database_authenticatable_patch'
require 'devise-security/models/paranoid_verification'
