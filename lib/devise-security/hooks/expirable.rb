# frozen_string_literal: true

# Warden hook for the +Expirable+ module.
#
# After each session set, updates +last_activity_at+ on the record to track
# when the user was last active. Only fires when the user is active for
# authentication and the record supports the +update_last_activity!+ method.
#
# Account expiry is checked during sign in via +active_for_authentication?+,
# not in this hook.
#
# Uses +devise_modules.include?(:expirable)+ to guard against models that
# do not include the module (consistent with session_limitable/session_traceable).
#
# @see Devise::Models::Expirable
Warden::Manager.after_set_user do |record, warden, options|
  scope = options[:scope]
  if record &&
     record.class.respond_to?(:devise_modules) &&
     record.class.devise_modules.include?(:expirable) &&
     record.respond_to?(:active_for_authentication?) &&
     record.active_for_authentication? &&
     warden.authenticated?(scope) &&
     record.respond_to?(:update_last_activity!)
    record.update_last_activity!
  end
end
