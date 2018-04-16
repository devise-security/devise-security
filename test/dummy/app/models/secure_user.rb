# frozen_string_literal: true

class SecureUser < ApplicationRecord
>>>>>>> origin/master
  devise :database_authenticatable, :secure_validatable, email_validation: false
end
