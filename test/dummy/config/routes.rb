# frozen_string_literal: true

RailsApp::Application.routes.draw do
  devise_for :users

  devise_for :captcha_users, only: [:sessions], controllers: { sessions: 'captcha/sessions' }
  devise_for :password_expiration_users, only: [:password_expired], controllers: { password_expired: 'overrides/password_expiration' }
  devise_for :security_question_users, only: [:sessions, :unlocks], controllers: { unlocks: 'security_question/unlocks' }

  resources :foos
  resource :widgets

  root to: 'widgets#show'
end
