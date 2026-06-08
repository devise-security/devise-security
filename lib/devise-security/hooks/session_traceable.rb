# frozen_string_literal: true

# Warden hooks for the +SessionTraceable+ module.
#
# Tracks individual sessions via +SessionHistory+ records, enabling
# configurable concurrent session limits (+max_active_sessions+),
# IP verification, and per-session expiration.
#
# Lifecycle:
# 1. *Login* — creates a +SessionHistory+ record with a unique token,
#    the client's IP address, and user agent. The token is stored in the
#    Warden session for subsequent validation.
# 2. *Fetch* — on each request, validates the token is still active (and
#    optionally matches the client IP). Updates +last_accessed_at+ on the
#    session record. Includes backward-compatibility migration from
#    +session_limitable+'s +unique_session_id+ to token-based tracking.
# 3. *Logout* — marks the +SessionHistory+ record as inactive and removes
#    the token from the Warden session.
#
# Skipped when the record returns +true+ from +skip_session_traceable?+
# or when the request env contains <tt>devise.skip_session_traceable</tt>.
#
# @see Devise::Models::SessionTraceable
# @see Devise::Models::SessionLimitable

# After each sign in, create a new +SessionHistory+ record.
# Logs the client IP and user agent. If +log_traceable_session!+ returns
# +nil+ (e.g., rejected by +session_limitable+), the user is logged out.
Warden::Manager.after_set_user except: :fetch do |record, warden, options|
  scope = options[:scope]
  if record.devise_modules.include?(:session_traceable) &&
     warden.authenticated?(scope) &&
     !record.skip_session_traceable? &&
     !warden.request.env['devise.skip_session_traceable']
    opts = {
      ip_address: warden.request.remote_ip,
      user_agent: warden.request.headers['User-Agent']
    }
    unique_traceable_token = record.log_traceable_session!(opts)
    if unique_traceable_token.present?
      warden.session(scope)['unique_traceable_token'] = unique_traceable_token
    else
      warden.logout(scope)
      throw(:warden, scope: scope, message: :unauthenticated)
    end
  end
end

# On each session fetch, validate the token and update +last_accessed_at+.
# Falls back to +session_limitable+'s +unique_session_id+ for backward
# compatibility, migrating the session to token-based tracking on first hit.
Warden::Manager.after_set_user only: :fetch do |record, warden, options|
  scope = options[:scope]
  if record.devise_modules.include?(:session_traceable) &&
     warden.authenticated?(scope) &&
     options[:store] != false &&
     !warden.request.env['devise.skip_session_traceable'] &&
     !record.skip_session_traceable?
    session = warden.session(scope)
    opts = { ip_address: warden.request.remote_ip }
    if session['unique_traceable_token'].present? &&
       record.accept_traceable_token?(session['unique_traceable_token'], opts)
      record.update_traceable_token!(session['unique_traceable_token'])
    elsif record.devise_modules.include?(:session_limitable) &&
          session['unique_session_id'].present? &&
          record.unique_session_id == session['unique_session_id']
      # Backward compatibility: migrate from session_limitable's unique_session_id
      # to session_traceable's token-based tracking.
      # TODO: Remove backward-compat migration path in next major release (v1.0)
      opts[:user_agent] = warden.request.headers['User-Agent']
      unique_traceable_token = record.log_traceable_session!(opts)
      session['unique_traceable_token'] = unique_traceable_token if unique_traceable_token.present?
      session.delete('unique_session_id')
    else
      warden.logout(scope)
      throw(:warden, scope: scope, message: :unauthenticated)
    end
  end
end

# On sign out, expire the +SessionHistory+ record and remove the token.
# Guard: +record+ can be nil when the session expired and Warden could not
# deserialize the user (see Warden::Proxy#logout — +@users.delete(scope)+
# returns nil). Matches the guard pattern in session_limitable's before_logout.
Warden::Manager.before_logout do |record, warden, options|
  scope = options[:scope]
  if record&.devise_modules&.include?(:session_traceable)
    session = warden.request.session["warden.user.#{scope}.session"]
    if session.present? && session['unique_traceable_token'].present?
      Rails.logger.debug { "[devise-security][session_traceable] expiring session token for #{record.class}##{record.id}" }
      record.expire_session_token!(session['unique_traceable_token'])
      session.delete('unique_traceable_token')
    end
  end
end
