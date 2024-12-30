# Devise Security

[![Build Status](https://github.com/devise-security/devise-security/actions/workflows/test_suite.yml/badge.svg?branch=main)](https://github.com/devise-security/devise-security/actions/workflows/test_suite.yml)
[![Coverage Status](https://coveralls.io/repos/github/devise-security/devise-security/badge.svg?branch=master)](https://coveralls.io/github/devise-security/devise-security?branch=main)
[![Maintainability](https://api.codeclimate.com/v1/badges/ace7cd003a0db8bffa5a/maintainability)](https://codeclimate.com/github/devise-security/devise-security/maintainability)

A [Devise](https://github.com/heartcombo/devise) extension to add additional
security features required by modern web applications. Forked from
[Devise Security Extension](https://github.com/phatworx/devise_security_extension)

It is composed of 7 additional Devise modules:

- `:password_expirable` - passwords will expire after a configured time (and
  will need to be changed by the user). You will most likely want to use
  `:password_expirable` together with the `:password_archivable` module to
  [prevent the current expired password from being reused](https://github.com/phatworx/devise_security_extension/issues/175)
  immediately as the new password.
- `:secure_validatable` - better way to validate a model (email, stronger
  password validation). Don't use with Devise `:validatable` module!
- `:password_archivable` - save used passwords in an `old_passwords` table for
  history checks (prevent reusing passwords)
- `:session_limitable` - ensures, that there is only one session usable per
  account at once
- `:expirable` - expires a user account after x days of inactivity (default 90
  days)
- `:security_questionable` - as accessible substitution for captchas (security
  question with captcha fallback)
- `:paranoid_verification` - admin can generate verification code that user
  needs to fill in otherwise he won't be able to use the application.

Configuration and database schema for each module below.

## Additional features

**captcha support** for `sign_up`, `sign_in`, `recover` and `unlock` (to make
automated mass creation and brute forcing of accounts harder)

## Getting started

Devise Security works with Devise on Rails >= 7.0. You can add it to your
Gemfile after you successfully set up Devise (see
[Devise documentation](https://github.com/heartcombo/devise)) with:

```ruby
gem 'devise-security'
```

Run the bundle command to install it.

After you installed Devise Security you need to run the generator:

```console
rails generate devise_security:install
```

The generator adds optional configurations to
`config/initializers/devise_security.rb`. Enable the modules you wish to use in
the initializer you are ready to add Devise Security modules on top of Devise
modules to any of your Devise models:

```ruby
devise :password_expirable, :secure_validatable, :password_archivable, :session_limitable, :expirable
```

### E-mail Validation

For `:secure_validatable` you need to have a way to validate an e-mail. There
are multiple libraries that support this, and even a way built into Ruby!

- (Recommended) Ruby built-in `URI::MailTo::EMAIL_REGEXP` constant
  > Note: This method would require a `email_validation` method to be defined in
  > order to hook into the `validates` method defined here.
- [email_address](https://github.com/afair/email_address) gem
- [valid_email2](https://github.com/micke/valid_email2) gem
- [rails_email_validator](https://github.com/phatworx/rails_email_validator) gem
  (deprecated)

## Configuration

```ruby
Devise.setup do |config|
  # ==> Security Extension
  # Configure security extension for devise

  # Password expires after a configurable time (in seconds).
  # Or expire passwords on demand by setting this configuration to `true`
  # Use `user.need_change_password!` to expire a password.
  # Setting the configuration to `false` will completely disable expiration checks.
  # config.expire_password_after = 3.months | true | false

  # Need 1 char each of: A-Z, a-z, 0-9, and a punctuation mark or symbol
  # You may use "digits" in place of "digit" and "symbols" in place of
  # "symbol" based on your preference
  # config.password_complexity = { digit: 1, lower: 1, symbol: 1, upper: 1 }

  # Number of old passwords in archive
  # config.password_archiving_count = 5

  # Deny old password (true, false, count)
  # config.deny_old_passwords = true

  # captcha integration for recover form
  # config.captcha_for_recover = true

  # captcha integration for sign up form
  # config.captcha_for_sign_up = true

  # captcha integration for sign in form
  # config.captcha_for_sign_in = true

  # captcha integration for unlock form
  # config.captcha_for_unlock = true

  # security_question integration for recover form
  # this automatically enables captchas (captcha_for_recover, as fallback)
  # config.security_question_for_recover = false

  # security_question integration for unlock form
  # this automatically enables captchas (captcha_for_unlock, as fallback)
  # config.security_question_for_unlock = false

  # security_question integration for confirmation form
  # this automatically enables captchas (captcha_for_confirmation, as fallback)
  # config.security_question_for_confirmation = false

  # ==> Configuration for :expirable
  # Time period for account expiry from last_activity_at
  # config.expire_after = 90.days

  # Allow passwords to be equal to email (false, true)
  # config.allow_passwords_equal_to_email = false

  # paranoid_verification will regenerate verification code after failed attempt
  # config.paranoid_code_regenerate_after_attempt = 10
end
```

## Other ORMs

Devise-security supports [Mongoid](https://rubygems.org/gems/mongoid) as an
alternative ORM to active_record. To use this ORM, add this to your `Gemfile`.

```ruby
gem 'mongoid'
```

And then ensure that the environment variable `DEVISE_ORM=mongoid` is set.

For local development you will need to have MongoDB installed locally.

```bash
brew install mongodb
```

### Rails App setup example with Mongoid

```ruby
# inside config/application.rb
    require File.expand_path('../boot', __FILE__)
    #...
    DEVISE_ORM=:mongoid

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
    Bundler.require(*Rails.groups)

    module MyApp
  class Application < Rails::Application
    #...
  end
end
```

## Captcha-Support

The captcha support depends on
[EasyCaptcha](https://github.com/phatworx/easy_captcha). See further
documentation there.

### Installation

1. Add EasyCaptcha to your `Gemfile` with

   ```ruby
   gem 'easy_captcha'
   ```

2. Run the initializer

   ```ruby
   rails generate easy_captcha:install
   ```

3. Enable captcha - see "Configuration" of Devise Security above.
4. Add the captcha in the generated devise views for each controller you have
   activated.

   ```erb
   <p><%= captcha_tag %></p>
   <p><%= text_field_tag :captcha %></p>
   ```

## Schema

### Password expirable

```ruby
create_table :the_resources do |t|
  # other devise fields

  t.datetime :password_changed_at
end
add_index :the_resources, :password_changed_at
```

Note: setting `password_changed_at` to `nil` will require the user to change
their password.

### Password archivable

```ruby
create_table :old_passwords do |t|
  t.string :encrypted_password, null: false
  t.string :password_archivable_type, null: false
  t.integer :password_archivable_id, null: false
  t.string :password_salt # Optional. bcrypt stores the salt in the encrypted password field so this column may not be necessary.
  t.datetime :created_at
end
add_index :old_passwords, [:password_archivable_type, :password_archivable_id], name: 'index_password_archivable'
```

### Session limitable

```ruby
create_table :the_resources do |t|
  # other devise fields

  t.string :unique_session_id
end
```

#### Bypassing session limitable

Sometimes it's useful to impersonate a user without authentication (e.g.
[administrator impersonating a user](https://github.com/heartcombo/devise/wiki/How-To:-Sign-in-as-another-user-if-you-are-an-admin)),
in this case the `session_limitable` strategy will log out the user, and if the
user logs in while the administrator is still logged in, the administrator will
be logged out.

For such cases the following can be used:

```ruby
sign_in(User.find(params[:id]), scope: :user, skip_session_limitable: true)
```

### Expirable

```ruby
create_table :the_resources do |t|
  # other devise fields

  t.datetime :last_activity_at
  t.datetime :expired_at
end
add_index :the_resources, :last_activity_at
add_index :the_resources, :expired_at
```

### Paranoid verifiable

```ruby
create_table :the_resources do |t|
  # other devise fields

  t.string   :paranoid_verification_code
  t.integer  :paranoid_verification_attempt, default: 0
  t.datetime :paranoid_verified_at
end
add_index :the_resources, :paranoid_verification_code
add_index :the_resources, :paranoid_verified_at
```

[Documentation for Paranoid Verifiable module](https://github.com/devise-security/devise-security/wiki/Paranoid-Verification)

### Security questionable

```ruby
# app/models/security_question.rb
class SecurityQuestion < ActiveRecord::Base
  validates :locale, presence: true
  validates :name, presence: true, uniqueness: true
end
```

```ruby
create_table :security_questions do |t|
  t.string :locale, null: false
  t.string :name, null: false
end

SecurityQuestion.create! locale: :de, name: 'Wie lautet der Geburstname Ihrer Mutter?'
SecurityQuestion.create! locale: :de, name: 'Wo sind sie geboren?'
SecurityQuestion.create! locale: :de, name: 'Wie lautet der Name Ihres ersten Haustieres?'
SecurityQuestion.create! locale: :de, name: 'Was ist Ihr Lieblingsfilm?'
SecurityQuestion.create! locale: :de, name: 'Was ist Ihr Lieblingsbuch?'
SecurityQuestion.create! locale: :de, name: 'Was ist Ihr Lieblingstier?'
SecurityQuestion.create! locale: :de, name: 'Was ist Ihr Lieblings-Reiseland?'
```

```ruby
add_column :the_resources, :security_question_id, :integer
add_column :the_resources, :security_question_answer, :string
```

or

```ruby
create_table :the_resources do |t|
  # other devise fields

  t.integer :security_question_id
  t.string :security_question_answer
end
```

## Requirements

- Devise (<https://github.com/heartcombo/devise>)
- Rails 7.0 onwards (<http://github.com/rails/rails>)
- recommendations:
  - `autocomplete-off` (<http://github.com/phatworx/autocomplete-off>)
  - `easy_captcha` (<http://github.com/phatworx/easy_captcha>)
  - `mongodb` (<https://www.mongodb.com/>)
  - `rvm` (<https://rvm.io/>)

## Todo

- see the github issues (feature requests)

## History

- 0.1 expire passwords
- 0.2 strong password validation
- 0.3 password archivable with validation
- 0.4 captcha support for sign_up, sign_in, recover and unlock
- 0.5 session_limitable module
- 0.6 expirable module
- 0.7 security questionable module for recover and unlock
- 0.8 Support for Rails 4 (+ variety of patches)
- 0.11 Support for Rails 5. Forked to allow project maintenance and features

See also
[Github Releases](https://github.com/devise-security/devise-security/releases)

## Maintainers

- Nate Bird (<https://github.com/natebird>)
- Kevin Olbrich (<http://github.com/olbrich>)
- Dillon Welch (<http://github.com/oniofchaos>)

## Contributing to devise-security

- Check out the latest main to make sure the feature hasn't been implemented
  or the bug hasn't been fixed yet
- Check out the issue tracker to make sure someone already hasn't requested it
  and/or contributed it
- Fork the project
- Start a feature/bugfix branch
- Commit and push until you are happy with your contribution
- Make sure to add tests for it. This is important so I don't break it in a
  future version unintentionally.
- Please try not to mess with the Rakefile, version, or history. If you want to
  have your own version, or is otherwise necessary, that is fine, but please
  isolate to its own commit so I can cherry-pick around it.

## Running tests

Standard tests can be invoked using `rake`. To run the tests against the
`mongoid` ORM, use `DEVISE_ORM=mongoid rake` while `mongodb` is running.

## Appraisal

It is possible to locally run the tests against multiple versions of Rails by using `appraisal`.

```sh
export DEVISE_ORM=active_record # or mongoid. Default is active_record
bundle exec appraisal # installs dependencies for each Rails version
bundle exec appraisal update # if updating dependencies is necessary
bundle exec appraisal generate # to regenerate the appraisal gemfiles (if necessary)
bundle exec appraisal rake # run the tests for each Rails version
```

## Maintenance Policy

We are committed to maintaining support for `devise-security` for all normal or
security maintenance versions of the Ruby language
[as listed here](https://www.ruby-lang.org/en/downloads/branches/), and for the
Ruby on Rails framework
[as per their maintenance policy](https://rubyonrails.org/maintenance/).

To avoid introducing bugs caused by backwardly incompatible Ruby
language features, it is highly recommended that all development work be done
using the oldest supported Ruby version. The contents of the `.ruby-version`
file should reflect this.

## Copyright

Copyright (c) 2017-2023 Dillon Welch & Kevin Olbrich.

Copyright (c) 2011-2017 Marco Scholl as the project [`devise_security_extension`](https://github.com/phatworx/devise_security_extension).

This repo was created as a fork from [b2ee978a](https://github.com/phatworx/devise_security_extension/commit/b2ee978af7d49f0fb0e7271c6ac074dfb4d39353).

See LICENSE.txt for further details.
