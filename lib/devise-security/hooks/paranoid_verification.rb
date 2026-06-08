# frozen_string_literal: true

# Warden hook for the +ParanoidVerification+ module.
#
# After each session set, checks whether paranoid verification is required
# and stores the result in the Warden session for the controller to act on.
#
# Uses +devise_modules.include?(:paranoid_verification)+ to guard against
# models that do not include the module (consistent with
# session_limitable/session_traceable).
#
# @see Devise::Models::ParanoidVerification
Warden::Manager.after_set_user do |record, warden, options|
  if record &&
     record.class.respond_to?(:devise_modules) &&
     record.class.devise_modules.include?(:paranoid_verification) &&
     record.respond_to?(:need_paranoid_verification?)
    warden.session(options[:scope])['paranoid_verify'] = record.need_paranoid_verification?
  end
end
