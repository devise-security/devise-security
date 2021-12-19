# frozen_string_literal: true

class WidgetsController < ApplicationController
  before_action :authenticate_user!

  def show
    render plain: 'success'
  end
end
