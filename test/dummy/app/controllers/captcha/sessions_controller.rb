# frozen_string_literal: true

class Captcha::SessionsController < Devise::SessionsController
  include DeviseSecurity::Patches::ControllerCaptcha
end
