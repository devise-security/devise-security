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

  def test_with_no_rules_anything_goes
    assert(ModelWithPassword.new('aaaa').valid?)
  end

  def test_enforces_uppercase
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { upper: 1 }
    assert_not(ModelWithPassword.new('aaaa').valid?)
    assert(ModelWithPassword.new('Aaaa').valid?)
  end

  def test_enforces_count
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { upper: 2 }
    assert_not(ModelWithPassword.new('Aaaa').valid?)
    assert(ModelWithPassword.new('AAaa').valid?)
  end

  def test_enforces_digit
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { digit: 1 }
    assert_not(ModelWithPassword.new('aaaa').valid?)
    assert(ModelWithPassword.new('aaa1').valid?)
  end

  def test_enforces_digits
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { digits: 2 }
    assert_not(ModelWithPassword.new('aaa1').valid?)
    assert(ModelWithPassword.new('aa12').valid?)
  end

  def test_enforces_lower
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { lower: 1 }
    assert_not(ModelWithPassword.new('AAAA').valid?)
    assert(ModelWithPassword.new('AAAa').valid?)
  end

  def test_enforces_symbol
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { symbol: 1 }
    assert_not(ModelWithPassword.new('aaaa').valid?)
    assert(ModelWithPassword.new('aaa!').valid?)
  end

  def test_enforces_symbols
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { symbols: 2 }
    assert_not(ModelWithPassword.new('aaa!').valid?)
    assert(ModelWithPassword.new('aa!?').valid?)
  end

  def test_enforces_combination
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { lower: 1, upper: 1, digit: 1, symbol: 1 }
    assert_not(ModelWithPassword.new('abcd').valid?)
    assert_not(ModelWithPassword.new('ABCD').valid?)
    assert_not(ModelWithPassword.new('1234').valid?)
    assert_not(ModelWithPassword.new('$!,*').valid?)
    assert(ModelWithPassword.new('aB3*').valid?)
  end
end
