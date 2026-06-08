# frozen_string_literal: true

module DeviseSecurity::Patches
  # Adds a security-question check as a +prepend_before_action+ on the
  # +create+ action of patched Devise controllers (passwords, unlocks,
  # confirmations). Included conditionally by {Patches.apply}.
  #
  # @see DeviseSecurity::Controllers::Helpers#valid_security_question_answer?
  module ControllerSecurityQuestion
    extend ActiveSupport::Concern

    included do
      prepend_before_action :check_security_question, only: [:create]
    end

    private

    # Looks up the resource by email and validates the security question answer.
    # If the answer is incorrect, sets a flash alert and redirects back to the
    # +new+ action, halting the controller chain.
    #
    # @return [void]
    def check_security_question
      # only find via email, not login
      resource = resource_class.find_or_initialize_with_error_by(:email, params[resource_name][:email], :not_found)
      return if valid_security_question_answer?(resource, params[:security_question_answer])

      flash[:alert] = t('devise.invalid_security_question') if is_navigational_format?
      respond_with({}, location: url_for(action: :new))
    end
  end
end
