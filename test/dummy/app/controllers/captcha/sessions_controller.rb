class Captcha::SessionsController < Devise::SessionsController
  include DeviseSecurity::Patches::ControllerCaptcha
end
