# frozen_string_literal: true

Devise.setup do |config|
  # ==> Security Extension
  # Configure security extension for devise

  # Should the password expire (e.g 3.months)
  # config.expire_password_after = false

  # Need 1 char each of: A-Z, a-z, 0-9, and a punctuation mark or symbol
  # You may use "digits" in place of "digit" and "symbols" in place of
  # "symbol" based on your preference
  # config.password_complexity = { digit: 1, lower: 1, symbol: 1, upper: 1 }

  # How many passwords to keep in archive
  # config.password_archiving_count = 5

  # Deny old passwords (true, false, number_of_old_passwords_to_check)
  # Examples:
  # config.deny_old_passwords = false # allow old passwords
  # config.deny_old_passwords = true # will deny all the old passwords
  # config.deny_old_passwords = 3 # will deny new passwords that matches with the last 3 passwords
  # config.deny_old_passwords = true

  # enable email validation for :secure_validatable. (true, false, validation_options)
  # dependency: see https://github.com/devise-security/devise-security/blob/main/README.md#e-mail-validation
  # config.email_validation = true

  # captcha integration for recover form
  # config.captcha_for_recover = true

  # captcha integration for sign up form
  # config.captcha_for_sign_up = true

  # captcha integration for sign in form
  # config.captcha_for_sign_in = true

  # captcha integration for unlock form
  # config.captcha_for_unlock = true

  # captcha integration for confirmation form
  # config.captcha_for_confirmation = true

  # Time period for account expiry from last_activity_at
  # config.expire_after = 90.days

  # Allow password to equal the email
  # config.allow_passwords_equal_to_email = false

  # paranoid_verification will regenerate verification code after failed attempt
  # config.paranoid_code_regenerate_after_attempt = 10

  # ==> Configuration for :session_limitable
  # Maximum number of concurrent sessions per user
  # config.max_active_sessions = 1

  # ==> Configuration for :session_traceable
  # Verify IP address matches the session's original IP
  # config.session_ip_verification = false

  # ==> Configuration for :expirable
  # Minimum interval between last_activity_at DB writes.
  # Reduces DB load on high-frequency authenticated requests.
  # config.last_activity_update_interval = nil

  # ==> Configuration for :password_archivable
  # Deny old passwords within a time period instead of by count
  # config.deny_old_passwords_period = nil

  # ==> Configuration for :secure_validatable
  # Require current password when changing email address
  # config.require_password_on_email_change = false
end
