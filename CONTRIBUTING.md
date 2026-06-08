# Contributing to devise-security

Thanks for your interest in contributing!

## Setup

```bash
git clone https://github.com/devise-security/devise-security.git
cd devise-security
bundle install
```

### Git hooks (Lefthook)

This project uses [Lefthook](https://github.com/evilmartians/lefthook) for git hooks.

```bash
# Install lefthook
brew install lefthook    # macOS
# or: gem install lefthook

# Activate hooks
lefthook install
```

**Pre-commit** runs RuboCop on changed files (with autofix) and validates YAML syntax.
Brakeman and the full test suite run in CI — not in local hooks.

## Running tests

```bash
# Full test suite (ActiveRecord, default)
bundle exec rake

# Specific ORM
DEVISE_ORM=mongoid bundle exec rake

# Specific Rails version (via appraisals)
BUNDLE_GEMFILE=gemfiles/rails_8.0.gemfile bundle exec rake

# Single test file
bundle exec ruby -Itest test/test_expirable.rb

# Single test by name
bundle exec ruby -Itest test/test_expirable.rb -n test_expire_sets_expired_at
```

## Running linters

```bash
bundle exec rubocop              # Ruby linting
bundle exec brakeman -p test/dummy -z -q   # Security scanning
```

## Pull request checklist

- [ ] Tests pass: `bundle exec rake`
- [ ] RuboCop clean: `bundle exec rubocop`
- [ ] Brakeman clean: `bundle exec brakeman -p test/dummy -z -q`
- [ ] `CHANGELOG.md` updated under `[Unreleased]` (CI enforces this)
- [ ] New features have tests
- [ ] New config options documented in README

## Changelog

This project follows [Keep a Changelog](https://keepachangelog.com/). Add your changes under the `## [Unreleased]` section in `CHANGELOG.md`, categorized as:

- **Added** — new features
- **Fixed** — bug fixes
- **Changed** — changes to existing functionality
- **Removed** — removed features
- **Deprecated** — soon-to-be removed features
- **Security** — vulnerability fixes

## Code style

- RuboCop enforces style — run `bundle exec rubocop --autocorrect` to fix most issues
- Tests use Minitest + FactoryBot
- YARD documentation on public methods
- Support both ActiveRecord and Mongoid ORMs

## Release process

Maintainers tag a release (`git tag v0.19.0 && git push --tags`). The [release workflow](.github/workflows/release.yml) automatically:

1. Reads the version's section from `CHANGELOG.md`
2. Creates a GitHub Release with those notes
3. Updates `CHANGELOG.md` to move `[Unreleased]` → `[version] - date`
