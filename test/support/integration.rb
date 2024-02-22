# frozen_string_literal: true

require 'warden/test/helpers'

class ActionDispatch::IntegrationTest
  include Warden::Test::Helpers

  # login the user.  This will exercise all the Warden Hooks
  # @param user [User]
  # @param session [ActionDispatch::Integration::Session]
  # @return scope [string]
  def sign_in(user, session = integration_session, scope = nil)
    scope ||= Devise::Mapping.find_scope!(user)
    session.post(
      send(:"new_#{scope}_session_path"),
      params: {
        "#{scope}": {
          email: user.email,
          password: 'Password1'
        }
      }
    )
    scope
  end

  # attempt to login the user with a bad password. This will exercise all the Warden Hooks
  # @param user [User]
  # @param session [ActionDispatch::Integration::Session]
  # @return scope [string]
  def failed_sign_in(user, session, scope = nil)
    scope ||= Devise::Mapping.find_scope!(user)
    session.post(
      send(:"new_#{scope}_session_path"),
      params: {
        "#{scope}": {
          email: user.email,
          password: 'bad-password'
        }
      }
    )
    scope
  end

  # logout the user.  This will exercise all the Warden Hooks
  # @param user [User]
  # @param session [ActionDispatch::Integration::Session]
  # @return [string]
  def sign_out(user, session = integration_session)
    scope = Devise::Mapping.find_scope!(user)
    session.get(
      send(:"destroy_#{scope}_session_path")
    )
    scope
  end
end
