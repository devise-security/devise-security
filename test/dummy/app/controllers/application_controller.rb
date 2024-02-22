# frozen_string_literal: true

class ApplicationController < ActionController::Base
  devise_group :customer, contains: %i[user traceable_user traceable_user_with_limit]
end
