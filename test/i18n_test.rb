# frozen_string_literal: true

require 'i18n/tasks'

class I18nTest < ActiveSupport::TestCase
  def setup
    @i18n = I18n::Tasks::BaseTask.new
    @missing_keys = @i18n.missing_keys
  end

  def test_no_missing_keys
    assert_empty @missing_keys,
                 "Missing #{@missing_keys.leaves.count} i18n keys, run `i18n-tasks missing' to show them"
  end

  def test_no_inconsistent_interpolations
    inconsistent_interpolations = @i18n.inconsistent_interpolations
    error_message = "#{inconsistent_interpolations.leaves.count} i18n keys have inconsistent interpolations.\n" \
                    "Please run `i18n-tasks check-consistent-interpolations' to show them"
    assert_empty inconsistent_interpolations, error_message
  end
end
