module IntegrationHelpers
  # login the user.  This will exercise all the Warden Hooks
  # @param user [User]
  # @param session [ActionDispatch::Integration::Session]
  # @return [void]
  # @note accounts for differences in the integration test API between rails versions
  def sign_in(user, session)
    if Rails.gem_version > Gem::Version.new('5.0')
      session.post new_user_session_path, params: {
        user: {
          email: user.email,
          password: user.password
        }
      }
    else
      session.post new_user_session_path, {
        user: {
          email: user.email,
          password: user.password
        }
      }
    end
  end

  # attempt to login the user with a bad password. This will exercise all the Warden Hooks
  # @param user [User]
  # @param session [ActionDispatch::Integration::Session]
  # @return [void]
  # @note accounts for differences in the integration test API between rails versions
  def failed_sign_in(user, session)
    if Rails.gem_version > Gem::Version.new('5.0')
      session.post new_user_session_path, params: {
        user: {
          email: user.email,
          password: 'bad-password'
        }
      }
    else
      session.post new_user_session_path, {
        user: {
          email: user.email,
          password: 'bad-password'
        }
      }
    end
  end
end
