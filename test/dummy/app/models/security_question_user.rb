# frozen_string_literal: true

class SecurityQuestionUser < ApplicationRecord
>>>>>>> origin/master
  self.table_name = 'users'
  devise :database_authenticatable, :password_archivable, :lockable,
         :paranoid_verification, :password_expirable, :security_questionable
end
