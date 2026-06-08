# frozen_string_literal: true

# Warden hook for the +PasswordExpirable+ module.
#
# After authentication, checks whether the user's password has expired
# and stores the result in the Warden session for the controller to act on.
#
# Uses +devise_modules.include?(:password_expirable)+ to guard against models
# that do not include the module (consistent with session_limitable/session_traceable).
#
# @see Devise::Models::PasswordExpirable
# @see DeviseSecurity::Controllers::Helpers#handle_password_change
Warden::Manager.after_authentication do |record, warden, options|
  if record &&
     record.class.respond_to?(:devise_modules) &&
     record.class.devise_modules.include?(:password_expirable) &&
     record.respond_to?(:need_change_password?)
    scope = options[:scope]
    expired = record.need_change_password?
    warden.session(scope)['password_expired'] = expired
    Rails.logger.debug { "[devise-security][password_expirable] password expired for #{record.class}##{record.id}" } if expired
  end
end
