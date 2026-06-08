# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- `:session_traceable` module — track active sessions per user via `session_histories` table with configurable `max_active_sessions` (based on PR #442 by @itsmechlark)
- Per-module migration generators: `rails g devise_security:install_<module> <Model>` (#295)
- Time-based password archive denial via `deny_old_passwords_period` config (#141)
- Throttle `update_last_activity!` to reduce DB writes via `last_activity_update_interval` (#494)
- Require current password for email change via `require_password_on_email_change` (#359)
- Proc support for `password_archiving_count` and `deny_old_passwords` (#453)
- Dynamic per-record config overrides via Proc or instance methods for all modules (#357)
- Env-based skip for session_limitable hooks via `devise.skip_session_limitable` (#421, #375)
- Full Mongoid compatibility for password_archivable, session_traceable, session_limitable, and expirable
- Missing `incorrect` i18n key added to all 20 locale files
- CHANGELOG.md following Keep a Changelog format
- CI: changelog enforcement on PRs, automated release notes from changelog

### Fixed

- `verify_code` always returned truthy, masking failed paranoid verifications
- Paranoid verification controller now adds error on failed code and re-renders form
- `:secure_validatable` exposes `@minimum_password_length` to controllers (#290)
- `login_attribute` nil crash (#351)
- `updated_at` now updates when setting `unique_session_id` (#350)
- `validators_on(:password)` discoverability restored via EachValidator wrappers (#441)
- Scoped uniqueness validation conflict with `:secure_validatable` (#448)
- `expired_for` scope fix (#449)

### Changed

- CI: consolidated rubocop.yml + brakeman.yml + test_suite.yml into single `ci.yml` with fail-fast lint gate
- CI: consolidated 3 nightly jobs into single `nightly.yml` with explicit matrix
- CI: updated CodeQL actions v2 → v3, Coveralls `@master` → `@v2`
- Refactored paranoid_verification with ActiveSupport::Concern and YARD docs (#206)
- Refactored password_archivable with YARD docs (#204)
- Refactored secure_validatable with YARD docs and DRY validators (#203)
- Refactored password_expirable with YARD docs (#193)
- Migrated test suite from fixtures to FactoryBot (#445)
- Standardized hook guards on `devise_modules.include?(:module_name)`
- Email validation: clear error message when EmailValidator gem missing (#339, #77)

### Removed

- Dead compatibility code for Rails < 5.1 (active_record_patch.rb methods)
- Dead compatibility code for Rails < 7.1 (migration API branch, password_expirable branch)
- Dead Rails < 5 engine branch from rails.rb
- Unused test helpers: `valid_new_attributes`, `clear_cached_variables`

## [0.18.0] - 2023-04-15

For changes prior to this changelog, see [GitHub Releases](https://github.com/devise-security/devise-security/releases).

[Unreleased]: https://github.com/devise-security/devise-security/compare/v0.18.0...HEAD
[0.18.0]: https://github.com/devise-security/devise-security/releases/tag/v0.18.0
