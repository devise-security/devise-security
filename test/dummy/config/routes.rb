# frozen_string_literal: true

RailsApp::Application.routes.draw do
  devise_for :users

  devise_for :non_devise_users
  devise_for :secure_users

  get '/secure_validatable_information', to: 'secure_validatable_information#index'

  devise_for :captcha_users, only: [:sessions], controllers: { sessions: 'captcha/sessions' }
  devise_for :security_question_users, only: [:sessions, :unlocks], controllers: { unlocks: 'security_question/unlocks' }

  resources :foos
  resource :widgets

  root to: 'widgets#show'
end
