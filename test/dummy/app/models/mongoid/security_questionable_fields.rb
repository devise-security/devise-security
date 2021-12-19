# frozen_string_literal: true

module SecurityQuestionableFields
  extend ::ActiveSupport::Concern

  included do
    include Mongoid::Document

    ## Security Questionable
    field :locked_at, type: Time
    field :unlock_token, type: String
    field :security_question_id, type: Integer
    field :security_question_answer, type: String
  end
end
