require 'test_helper'

class Validatable
  include ActiveModel::Validations

  attr_reader :complex_string

  def initialize(complex_string)
    @complex_string = complex_string
  end
end

class NoRules < Validatable
  validates :complex_string, 'devise_security/complexity': {}
end

class OneUpper < Validatable
  validates :complex_string, 'devise_security/complexity': { upper: 1 }
end

class TwoUpper < Validatable
  validates :complex_string, 'devise_security/complexity': { upper: 2 }
end

class OneDigit < Validatable
  validates :complex_string, 'devise_security/complexity': { digit: 1 }
end

class OneLower < Validatable
  validates :complex_string, 'devise_security/complexity': { lower: 1 }
end

class OneSymbol < Validatable
  validates :complex_string, 'devise_security/complexity': { lower: 1 }
end

class OneOfEach < Validatable
  validates :complex_string, 'devise_security/complexity': { lower: 1, upper: 1, digit: 1, symbol: 1 }
end

class EmailValidatorTest < Minitest::Test
  def with_no_rules_anything_goes
    assert(NoRules.new('aaaa').valid?)
  end

  def enforces_uppercase
    refute(OneUpper.new('aaaa').valid?)
    assert(OneUpper.new('Aaaa').valid?)
  end

  def enforces_count
    refute(TwoUpper.new('Aaaa').valid?)
    assert(TwoUpper.new('AAaa').valid?)
  end

  def enforces_digit
    refute(OneDigit.new('aaaa').valid?)
    assert(OneUpper.new('aaa1').valid?)
  end

  def enforces_lower
    refute(OneLower.new('AAAA').valid?)
    assert(OneLower.new('AAAa').valid?)
  end

  def enforces_symbol
    refute(OneSymbol.new('aaaa').valid?)
    assert(OneSymbol.new('aaa!').valid?)
  end

  def enforces_combination
    refute(OneOfEach.new('abcd').valid?)
    refute(OneOfEach.new('ABCD').valid?)
    refute(OneOfEach.new('1234').valid?)
    refute(OneOfEach.new('$!,*').valid?)
    assert(OneOfEach.new('aB3*').valid?)
  end
end
