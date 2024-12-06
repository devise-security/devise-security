# frozen_string_literal: true

module IntegrationHelpers
  # login the user.  This will exercise all the Warden Hooks
  # @param user [User]
  # @param session [ActionDispatch::Integration::Session]
  # @return [void]
  def sign_in(user, session = integration_session)
    session.post(
      new_user_session_path,
      params: {
        user: {
          email: user.email,
          password: user.password
        }
      }
    )
  end

  # attempt to login the user with a bad password. This will exercise all the Warden Hooks
  # @param user [User]
  # @param session [ActionDispatch::Integration::Session]
  # @return [void]
  def failed_sign_in(user, session)
    session.post(
      new_user_session_path,
      params: {
        user: {
          email: user.email,
          password: 'bad-password'
        }
      }
    )
  end

  # logout the user.  This will exercise all the Warden Hooks
  # @param session [ActionDispatch::Integration::Session]
  # @return [void]
  def sign_out(session = integration_session)
    session.delete(destroy_user_session_path)
  end
end
