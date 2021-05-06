# frozen_string_literal: true

# @note This happens after
#   {DeviseSecurity::Controller::Helpers#handle_password_change}
Warden::Manager.after_authentication do |record, warden, options|
  break unless record.respond_to?(:need_change_password?)

  warden.session(options[:scope])['password_expired'] = record.need_change_password?
end
