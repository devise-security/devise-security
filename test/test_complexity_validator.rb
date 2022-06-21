# frozen_string_literal: true

require 'test_helper'

class PasswordComplexityValidatorTest < ActiveSupport::TestCase
  class ModelWithPassword
    include ActiveModel::Validations

    attr_reader :password

    def initialize(password)
      @password = password
    end
  end

  def setup
    ModelWithPassword.clear_validators!
  end

  def create_model(password, opts = {})
    ModelWithPassword.validates(
      :password, 'devise_security/password_complexity': opts
    )
    ModelWithPassword.new(password)
  end

  def test_with_no_rules_anything_goes
    assert(create_model('aaaa').valid?)
  end

  def test_allows_blank
    assert(create_model('', { upper: 1 }).valid?)
  end

  def test_enforces_uppercase_invalid
    model = create_model('aaaa', { upper: 1 })

    assert_not(model.valid?)
    assert_equal(
      { password: ['must contain at least one upper-case letter'] },
      model.errors.messages
    )
  end

  def test_enforces_uppercase_valid
    assert(create_model('Aaaa', { upper: 1 }).valid?)
  end

  def test_enforces_uppercase_count_invalid
    model = create_model('Aaaa', { upper: 2 })

    assert_not(model.valid?)
    assert_equal(
      { password: ['must contain at least 2 upper-case letters'] },
      model.errors.messages
    )
  end

  def test_enforces_uppercase_count_valid
    assert(create_model('AAaa', { upper: 2 }).valid?)
  end

  def test_enforces_digit_invalid
    model = create_model('aaaa', { digit: 1 })

    assert_not(model.valid?)
    assert_equal(
      { password: ['must contain at least one digit'] }, model.errors.messages
    )
  end

  def test_enforces_digit_valid
    assert(create_model('1aaa', { digit: 1 }).valid?)
  end

  def test_enforces_digit_count_invalid
    model = create_model('1aaa', { digit: 2 })

    assert_not(model.valid?)
    assert_equal(
      { password: ['must contain at least 2 digits'] }, model.errors.messages
    )
  end

  def test_enforces_digit_count_valid
    assert(create_model('11aa', { digit: 2 }).valid?)
  end

  def test_enforces_digits_invalid
    model = create_model('aaaa', { digits: 1 })

    assert_not(model.valid?)
    assert_equal(
      { password: ['must contain at least one digit'] }, model.errors.messages
    )
  end

  def test_enforces_digits_valid
    assert(create_model('1aaa', { digits: 1 }).valid?)
  end

  def test_enforces_digits_count_invalid
    model = create_model('1aaa', { digits: 2 })

    assert_not(model.valid?)
    assert_equal(
      { password: ['must contain at least 2 digits'] }, model.errors.messages
    )
  end

  def test_enforces_digits_count_valid
    assert(create_model('11aa', { digits: 2 }).valid?)
  end

  def test_enforces_lower_invalid
    model = create_model('AAAA', { lower: 1 })

    assert_not(model.valid?)
    assert_equal(
      { password: ['must contain at least one lower-case letter'] },
      model.errors.messages
    )
  end

  def test_enforces_lower_valid
    assert(create_model('aAAA', { lower: 1 }).valid?)
  end

  def test_enforces_lower_count_invalid
    model = create_model('aAAA', { lower: 2 })

    assert_not(model.valid?)
    assert_equal(
      { password: ['must contain at least 2 lower-case letters'] },
      model.errors.messages
    )
  end

  def test_enforces_lower_count_valid
    assert(create_model('aaAA', { lower: 2 }).valid?)
  end

  def test_enforces_symbol_invalid
    model = create_model('aaaa', { symbol: 1 })

    assert_not(model.valid?)
    assert_equal(
      { password: ['must contain at least one punctuation mark or symbol'] },
      model.errors.messages
    )
  end

  def test_enforces_symbol_valid
    assert(create_model('!aaa', { symbol: 1 }).valid?)
  end

  def test_enforces_symbol_count_invalid
    model = create_model('!aaa', { symbol: 2 })

    assert_not(model.valid?)
    assert_equal(
      { password: ['must contain at least 2 punctuation marks or symbols'] },
      model.errors.messages
    )
  end

  def test_enforces_symbol_count_valid
    assert(create_model('!!aa', { symbol: 2 }).valid?)
  end

  def test_enforces_symbols_invalid
    model = create_model('aaaa', { symbols: 1 })

    assert_not(model.valid?)
    assert_equal(
      { password: ['must contain at least one punctuation mark or symbol'] },
      model.errors.messages
    )
  end

  def test_enforces_symbols_valid
    assert(create_model('!aaa', { symbols: 1 }).valid?)
  end

  def test_enforces_symbols_count_invalid
    model = create_model('!aaa', { symbols: 2 })

    assert_not(model.valid?)
    assert_equal(
      { password: ['must contain at least 2 punctuation marks or symbols'] },
      model.errors.messages
    )
  end

  def test_enforces_symbols_count_valid
    assert(create_model('!!aa', { symbols: 2 }).valid?)
  end

  def test_enforces_combination_only_lower_invalid
    model = create_model('aaaa', { lower: 1, upper: 1, digit: 1, symbol: 1 })

    assert_not(model.valid?)
    assert_equal(
      {
        password:
        [
          'must contain at least one digit',
          'must contain at least one punctuation mark or symbol',
          'must contain at least one upper-case letter'
        ]
      },
      model.errors.messages
    )
  end

  def test_enforces_combination_only_upper_invalid
    model = create_model('AAAA', { lower: 1, upper: 1, digit: 1, symbol: 1 })

    assert_not(model.valid?)
    assert_equal(
      {
        password:
        [
          'must contain at least one digit',
          'must contain at least one lower-case letter',
          'must contain at least one punctuation mark or symbol'
        ]
      },
      model.errors.messages
    )
  end

  def test_enforces_combination_only_digit_invalid
    model = create_model('1111', { lower: 1, upper: 1, digit: 1, symbol: 1 })

    assert_not(model.valid?)
    assert_equal(
      {
        password:
        [
          'must contain at least one lower-case letter',
          'must contain at least one punctuation mark or symbol',
          'must contain at least one upper-case letter'
        ]
      },
      model.errors.messages
    )
  end

  def test_enforces_combination_only_symbol_invalid
    model = create_model('!!!!', { lower: 1, upper: 1, digit: 1, symbol: 1 })

    assert_not(model.valid?)
    assert_equal(
      {
        password:
        [
          'must contain at least one digit',
          'must contain at least one lower-case letter',
          'must contain at least one upper-case letter'
        ]
      },
      model.errors.messages
    )
  end

  def test_enforces_combination_some_but_not_all_invalid
    model = create_model('aAa!', { lower: 1, upper: 1, digit: 1, symbol: 1 })

    assert_not(model.valid?)
    assert_equal(
      { password: ['must contain at least one digit'] },
      model.errors.messages
    )
  end

  def test_enforces_combination_all_valid
    model = create_model('aA1!', { lower: 1, upper: 1, digit: 1, symbol: 1 })

    assert(model.valid?)
  end
end
