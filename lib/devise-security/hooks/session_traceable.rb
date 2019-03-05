# frozen_string_literal: true

# After each sign in, create new traceable session.
# This is only triggered when the user is explicitly set (with set_user)
# and on authentication. Retrieving the user from session (:fetch) does
# not trigger it.
Warden::Manager.after_set_user except: :fetch do |record, warden, options|
  scope = options[:scope]
  if record.respond_to?(:log_traceable_session!) && warden.authenticated?(options[:scope])
    opts = {
      ip_address: warden.request.remote_ip,
      user_agent: warden.request.headers['User-Agent'],
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
  if record.respond_to?(:accept_traceable_token?) &&
     warden.authenticated?(scope) &&
     options[:store] != false &&
     !env['devise.skip_session_traceable']
    opts = { ip_address: warden.request.remote_ip }
    session = warden.session(scope)
    if session['unique_traceable_token'].present? &&
       record.accept_traceable_token?(session['unique_traceable_token'], opts)
      record.update_traceable_token(session['unique_traceable_token'])
    else
      warden.logout(scope)
      throw(:warden, scope: scope, message: :unauthenticated)
    end
  end
end

# Before each sign out, we expire the session and remove the token.
Warden::Manager.before_logout do |record, warden, options|
  session = warden.request.session["warden.user.#{options[:scope]}.session"]
  if record.respond_to?(:expire_session_token) &&
     session.present? &&
     session['unique_traceable_token'].present?
    record.expire_session_token(session['unique_traceable_token'])
    session.delete('unique_traceable_token')
  end
end
