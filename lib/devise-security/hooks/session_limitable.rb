# frozen_string_literal: true

# Warden hooks for the +SessionLimitable+ module.
#
# Enforces that only one active session exists per user at a time (or up to
# +max_active_sessions+ when combined with +SessionTraceable+).
#
# Lifecycle:
# 1. *Login* — assigns a +unique_session_id+ to the user and stores it in
#    the Warden session.
# 2. *Fetch* — on each request, compares the stored session id with the
#    user's current +unique_session_id+. A mismatch means another session
#    superseded this one, so the old session is logged out.
# 3. *Logout* — clears the +unique_session_id+ to prevent session replay.
#
# Skipped when +session_traceable+ is included (traceable hooks take over),
# when the record returns +true+ from +skip_session_limitable?+, or when
# the request env contains <tt>devise.skip_session_limitable</tt>.
#
# @see Devise::Models::SessionLimitable

# After each sign in, assign a new +unique_session_id+.
# Only triggered on explicit authentication, not on session fetch.
Warden::Manager.after_set_user except: :fetch do |record, warden, options|
  scope = options[:scope]
  if record.devise_modules.exclude?(:session_traceable) &&
     record.devise_modules.include?(:session_limitable) &&
     warden.authenticated?(scope) &&
     !record.skip_session_limitable? &&
     !warden.request.env['devise.skip_session_limitable']

    unique_session_id = Devise.friendly_token
    warden.session(scope)['unique_session_id'] = unique_session_id
    record.update_unique_session_id!(unique_session_id)
  end
end

# On each session fetch, verify that the stored session id still matches
# the user's current +unique_session_id+. If another login has superseded
# this session, clear the session and redirect to sign in.
Warden::Manager.after_set_user only: :fetch do |record, warden, options|
  scope = options[:scope]

  if record.devise_modules.exclude?(:session_traceable) &&
     record.devise_modules.include?(:session_limitable) &&
     warden.authenticated?(scope) &&
     options[:store] != false && record.unique_session_id != warden.session(scope)['unique_session_id'] &&
     !record.skip_session_limitable? &&
     !warden.request.env['devise.skip_session_limitable']
    Rails.logger.warn do
      '[devise-security][session_limitable] session id mismatch: ' \
        "expected=#{record.unique_session_id.inspect} " \
        "actual=#{warden.session(scope)['unique_session_id'].inspect}"
    end
    warden.raw_session.clear
    warden.logout(scope)
    throw :warden, scope: scope, message: :session_limited
  end
end

# On sign out, clear the +unique_session_id+ to prevent session replay.
Warden::Manager.before_logout do |record, _warden, _options|
  if record&.devise_modules&.include?(:session_limitable) &&
     !record.skip_session_limitable?
    record.update_unique_session_id!(nil)
  end
end
