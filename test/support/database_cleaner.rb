# frozen_string_literal: true

module DatabaseCleanerLifecycleHooks
  def self.included(_base)
    DatabaseCleaner.clean
  end

  def setup
    DatabaseCleaner.start
  end

  def teardown
    DatabaseCleaner.clean
  end
end

class ActiveSupport::TestCase
  include DatabaseCleanerLifecycleHooks
end
