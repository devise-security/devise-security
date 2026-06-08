# frozen_string_literal: true

require 'test_helper'

# Requirement: When a model uses :secure_validatable, Devise controllers
# should expose @minimum_password_length and @minimum_password_complexity
# to views, just like :validatable exposes @minimum_password_length.
#
# See: https://github.com/devise-security/devise-security/issues/290
class TestSecureValidatableControllerInfo < ActiveSupport::TestCase
  test 'set_minimum_password_length sets @minimum_password_length for secure_validatable mapping' do
    mapping = Devise.mappings[:user]

    assert_predicate mapping, :secure_validatable?,
                     'Expected :user mapping to include :secure_validatable'

    controller = build_controller_with_mapping(mapping)
    controller.send(:set_minimum_password_length)

    assert_equal mapping.to.password_length.min,
                 controller.instance_variable_get(:@minimum_password_length)
  end

  test 'set_minimum_password_length sets @minimum_password_complexity for secure_validatable mapping' do
    mapping = Devise.mappings[:user]

    assert_predicate mapping, :secure_validatable?,
                     'Expected :user mapping to include :secure_validatable'

    controller = build_controller_with_mapping(mapping)
    controller.send(:set_minimum_password_length)

    assert_equal mapping.to.password_complexity,
                 controller.instance_variable_get(:@minimum_password_complexity)
  end

  test 'set_minimum_password_length preserves original validatable behavior' do
    mapping = Devise.mappings[:user]

    assert_predicate mapping, :validatable?,
                     'Expected :user mapping to include :validatable'

    controller = build_controller_with_mapping(mapping)
    controller.send(:set_minimum_password_length)

    assert_equal mapping.to.password_length.min,
                 controller.instance_variable_get(:@minimum_password_length)
  end

  test 'set_minimum_password_length does not set variables when neither module present' do
    stub_mapping = Object.new
    stub_mapping.define_singleton_method(:validatable?) { false }
    stub_mapping.define_singleton_method(:secure_validatable?) { false }

    controller = build_controller_with_mapping(stub_mapping)
    controller.send(:set_minimum_password_length)

    assert_nil controller.instance_variable_get(:@minimum_password_length)
    assert_nil controller.instance_variable_get(:@minimum_password_complexity)
  end

  private

  # Build a DeviseController instance with a stubbed devise_mapping.
  # This avoids needing a full request/env setup.
  def build_controller_with_mapping(mapping)
    controller = DeviseController.allocate
    controller.define_singleton_method(:devise_mapping) { mapping }
    controller
  end
end
