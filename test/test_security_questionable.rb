# frozen_string_literal: true

require 'test_helper'

class TestSecurityQuestionable < ActiveSupport::TestCase
  test 'should have required_fields array' do
    assert_equal(
      [:security_question_id, :security_question_answer],
      Devise::Models::SecurityQuestionable.required_fields(User)
    )
  end
end
