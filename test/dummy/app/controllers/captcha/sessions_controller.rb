# frozen_string_literal: true

class Captcha::SessionsController < Devise::SessionsController
  # This includes the methods necessary for Captcha support in the controller
  include DeviseSecurity::Patches::ControllerCaptcha
end
