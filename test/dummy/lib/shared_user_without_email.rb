# frozen_string_literal: true

module SharedUserWithoutEmail
  extend ActiveSupport::Concern

  included do
    # NOTE: This is missing :validatable and :confirmable, as they both require
    # an email field at the moment. It is also missing :omniauthable because that
    # adds unnecessary complexity to the setup
    devise :database_authenticatable, :lockable, :recoverable,
           :registerable, :rememberable, :timeoutable,
           :trackable
  end
end
