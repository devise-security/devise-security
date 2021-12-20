require 'test_helper'

require 'benchmark'

module Performance
  class UserTest < ActiveSupport::TestCase
    class ConfigOffUser < User
      self.allow_passwords_equal_to_email = true
    end

    class ConfigOnUser < User
      self.allow_passwords_equal_to_email = false
    end

    test 'equal to email validation is performant for valid passwords' do
      user1 = ConfigOffUser.new(email: 'speed@aol.com', password: 'Password1!')
      user1.valid?
      user2 = ConfigOnUser.new(email: 'speed@aol.com', password: 'Password1!')
      user2.valid?

      result1 = Benchmark.measure { user1.valid? }
      result2 = Benchmark.measure { user2.valid? }

      assert_in_delta(result1.real, result2.real, 0.005)
    end

    test 'equal to email validation is performant for invalid passwords' do
      email = 'speed@aol.com'
      user1 = ConfigOffUser.new(email: email, password: email)
      user1.valid?
      user2 = ConfigOnUser.new(email: email, password: email)
      user2.valid?

      GC.start
      result1 = Benchmark.measure { user1.valid? }
      GC.start
      result2 = Benchmark.measure { user2.valid? }

      assert_in_delta(result1.real, result2.real, 0.005)
    end
  end
end
