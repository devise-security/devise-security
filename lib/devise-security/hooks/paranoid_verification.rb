# frozen_string_literal: true

Warden::Manager.after_set_user do |record, warden, options|
  break unless record.respond_to?(:need_paranoid_verification?)

  warden.session(options[:scope])['paranoid_verify'] = record.need_paranoid_verification?
end
