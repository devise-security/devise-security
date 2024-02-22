# frozen_string_literal: true

# After each sign in, create new traceable session.
# This is only triggered when the user is explicitly set (with set_user)
# and on authentication. Retrieving the user from session (:fetch) does
# not trigger it.
Warden::Manager.after_set_user except: :fetch do |record, warden, options|
  scope = options[:scope]
  if record.devise_modules.include?(:session_traceable) &&
     warden.authenticated?(options[:scope]) &&
     !record.skip_session_traceable?
    opts = {
      ip_address: warden.request.remote_ip,
      user_agent: warden.request.headers['User-Agent']
    }
    unique_traceable_token = record.log_traceable_session!(opts)
    if unique_traceable_token.present?
      warden.session(options[:scope])['unique_traceable_token'] = unique_traceable_token
    else
      warden.logout(scope)
      throw(:warden, scope: scope, message: :unauthenticated)
    end
  end
end

# Each time a record is fetched from session we verify if the session
# has a valid unique session identifier. If so, then we set the last accessed time.
Warden::Manager.after_set_user only: :fetch do |record, warden, options|
  scope = options[:scope]
  env = warden.request.env
  opts = { ip_address: warden.request.remote_ip }
  if record.devise_modules.include?(:session_traceable) &&
     warden.authenticated?(scope) &&
     options[:store] != false &&
     !env['devise.skip_session_traceable'] &&
     !record.skip_session_traceable?
    session = warden.session(scope)
    if session['unique_traceable_token'].present? &&
       record.accept_traceable_token?(session['unique_traceable_token'], opts)
      record.update_traceable_token(session['unique_traceable_token'])
    elsif record.devise_modules.include?(:session_limitable) &&
          session['unique_session_id'].present? &&
          record.unique_session_id == session['unique_session_id']
      # Backward compatibility for session_limitable
      # TODO: Remove in future release
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

# Before each sign out, we expire the session and remove the token.
Warden::Manager.before_logout do |record, warden, options|
  session = warden.request.session["warden.user.#{options[:scope]}.session"]
  if session.present? &&
     session['unique_traceable_token'].present?
    record.expire_session_token(session['unique_traceable_token'])
    session.delete('unique_traceable_token')
  end
end
