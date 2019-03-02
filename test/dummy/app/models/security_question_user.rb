# frozen_string_literal: true

class SecurityQuestionUser < ApplicationUserRecord
  devise :database_authenticatable, :lockable, :security_questionable
  if DEVISE_ORM == :mongoid
    require './test/dummy/app/models/mongoid/mappings'
    include ::Mongoid::Mappings
    field :security_question_answer, type: String
  end
end
