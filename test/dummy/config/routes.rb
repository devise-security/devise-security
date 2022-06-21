# frozen_string_literal: true

RailsApp::Application.routes.draw do
  devise_for :users

  devise_for :captcha_users, only: [:sessions], controllers: { sessions: 'captcha/sessions' }
  devise_for :password_expired_users, only: [:password_expired], controllers: { password_expired: 'overrides/password_expired' }
  devise_for :paranoid_verification_users, only: [:verification_code], controllers: { paranoid_verification_code: 'overrides/paranoid_verification_code' }
  devise_for :security_question_users, only: %i[sessions unlocks], controllers: { unlocks: 'security_question/unlocks' }

  resources :foos
  resource :widgets

  root to: 'widgets#show'
end
