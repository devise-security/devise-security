# frozen_string_literal: true
require 'shared_user'

module SharedSecurityQuestionsFields
  extend ActiveSupport::Concern

  included do
    include SharedUser
    devise :lockable, :security_questionable

    field :locked_at, type: Time
    field :unlock_token, type: String
    field :security_question_id, type: Integer
    field :security_question_answer, type: String
  end
end
