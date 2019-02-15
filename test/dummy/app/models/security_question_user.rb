# frozen_string_literal: true

class SecurityQuestionUser < ApplicationRecord
  self.table_name = 'users' if DEVISE_ORM == :active_record
  devise :database_authenticatable, :lockable, :security_questionable
  if DEVISE_ORM == :mongoid
    require './test/dummy/app/models/mongoid/mappings'
    include Mongoid::Mappings
    field :security_question_answer, type: String
  end
end

# if DEVISE_ORM == :active_record
#   class SecurityQuestionUser
#     devise :database_authenticatable, :lockable, :security_questionable
#     self.table_name = 'users'
#   end
# elsif DEVISE_ORM == :mongoid
#   class SecurityQuestionUser
#     include Mongoid::Document
#     require './test/dummy/app/models/mongoid/mappings'
#     include Mongoid::Mappings
#   end
# end