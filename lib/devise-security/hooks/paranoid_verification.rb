# frozen_string_literal: true

Warden::Manager.after_set_user do |record, warden, options|
  warden.session(options[:scope])['paranoid_verify'] = record.need_paranoid_verification? if record.respond_to?(:need_paranoid_verification?)
end
