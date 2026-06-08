# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  devise_group :customer, contains: %i[user traceable_user traceable_user_with_limit]
end
