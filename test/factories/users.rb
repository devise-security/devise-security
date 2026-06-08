# frozen_string_literal: true

FactoryBot.define do
  sequence(:email) { |n| "factory#{n}@example.com" }
  sequence(:username) { |n| "factory#{n}" }

  factory :user do
    email { generate(:email) }
    username { generate(:username) }
    password { 'Password1' }
  end

  factory :traceable_user, class: 'TraceableUser' do
    email { generate(:email) }
    username { generate(:username) }
    password { 'Password1' }
  end

  factory :traceable_user_with_limit, class: 'TraceableUserWithLimit' do
    email { generate(:email) }
    username { generate(:username) }
    password { 'Password1' }
  end

  factory :paranoid_verification_user, class: 'ParanoidVerificationUser' do
    email { generate(:email) }
    username { generate(:username) }
    password { 'Password1' }
  end

  factory :security_question_user, class: 'SecurityQuestionUser' do
    email { generate(:email) }
    username { generate(:username) }
    password { 'Password1' }
  end

  factory :captcha_user, class: 'CaptchaUser' do
    email { generate(:email) }
    username { generate(:username) }
    password { 'Password1' }
  end

  factory :password_expired_user, class: 'PasswordExpiredUser' do
    email { generate(:email) }
    username { generate(:username) }
    password { 'Password1' }
  end
end
