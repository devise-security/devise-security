require 'test_helper'

class PasswordComplexityValidatorTest < Minitest::Test
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
    refute(ModelWithPassword.new('aaaa').valid?)
    assert(ModelWithPassword.new('Aaaa').valid?)
  end

  def test_enforces_count
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { upper: 2 }
    refute(ModelWithPassword.new('Aaaa').valid?)
    assert(ModelWithPassword.new('AAaa').valid?)
  end

  def test_enforces_digit
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { digit: 1 }
    refute(ModelWithPassword.new('aaaa').valid?)
    assert(ModelWithPassword.new('aaa1').valid?)
  end

  def test_enforces_digits
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { digits: 2 }
    refute(ModelWithPassword.new('aaa1').valid?)
    assert(ModelWithPassword.new('aa12').valid?)
  end

  def test_enforces_lower
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { lower: 1 }
    refute(ModelWithPassword.new('AAAA').valid?)
    assert(ModelWithPassword.new('AAAa').valid?)
  end

  def test_enforces_symbol
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { symbol: 1 }
    refute(ModelWithPassword.new('aaaa').valid?)
    assert(ModelWithPassword.new('aaa!').valid?)
  end

  def test_enforces_symbols
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { symbols: 2 }
    refute(ModelWithPassword.new('aaa!').valid?)
    assert(ModelWithPassword.new('aa!?').valid?)
  end

  def test_enforces_combination
    ModelWithPassword.validates :password, 'devise_security/password_complexity': { lower: 1, upper: 1, digit: 1, symbol: 1 }
    refute(ModelWithPassword.new('abcd').valid?)
    refute(ModelWithPassword.new('ABCD').valid?)
    refute(ModelWithPassword.new('1234').valid?)
    refute(ModelWithPassword.new('$!,*').valid?)
    assert(ModelWithPassword.new('aB3*').valid?)
  end
end
