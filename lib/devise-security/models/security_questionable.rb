# frozen_string_literal: true

module Devise
  module Models
    # SecurityQuestionable provides an accessible alternative to CAPTCHAs
    # for screenreader-compatible authentication flows. Users select a
    # security question at registration and answer it on sensitive forms
    # (unlock, password reset, confirmation).
    #
    # == How it works
    # 1. User selects a question and provides an answer during registration.
    # 2. On sensitive actions (password reset, unlock, confirmation), the
    #    answer is validated via {DeviseSecurity::Controllers::Helpers#valid_security_question_answer?}.
    # 3. If the answer is wrong, {DeviseSecurity::Patches::ControllerSecurityQuestion}
    #    halts the request and redirects back with a flash alert.
    #
    # == Database columns
    # - +security_question_id+ (+Integer+) — FK to the +SecurityQuestion+ model
    # - +security_question_answer+ (+String+) — the user's stored answer
    #
    # == Form Setup
    # Add to unlock, password, and confirmation forms:
    #   text_field_tag :security_question_answer
    #   text_field_tag :captcha
    #
    # Add to registration/edit forms:
    #   f.select :security_question_id, SecurityQuestion.where(locale: I18n.locale).map { |s| [s.name, s.id] }
    #   f.text_field :security_question_answer
    #
    # == Configuration
    # Enable per-controller via Devise config flags:
    # - +Devise.security_question_for_recover+
    # - +Devise.security_question_for_unlock+
    # - +Devise.security_question_for_confirmation+
    #
    # @see SecurityQuestion the model storing available questions per locale
    # @see Devise::Models::DatabaseAuthenticatable required base module
    # @see DeviseSecurity::Patches::ControllerSecurityQuestion controller integration
    module SecurityQuestionable
      extend ActiveSupport::Concern

      # @param _klass [Class] the model class including this module
      # @return [Array<Symbol>] required database columns
      def self.required_fields(_klass)
        %i[security_question_id security_question_answer]
      end
    end
  end
end
