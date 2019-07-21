# frozen_string_literal: true

require_relative 'compatibility'
require 'devise-security/hooks/session_limitable'

module Devise
  module Models
    # SessionLimited ensures, that there is only one session usable per account at once.
    # If someone logs in, and some other is logging in with the same credentials,
    # the session from the first one is invalidated and not usable anymore.
    # The first one is redirected to the sign page with a message, telling that
    # someone used his credentials to sign in.
    module SessionLimitable
      extend ActiveSupport::Concern
      include Devise::Models::Compatibility

      # Update the unique_session_id on the model.  This will be checked in
      # the Warden after_set_user hook in {file:devise-security/hooks/session_limitable}
      # @param unique_session_id [String]
      # @return [void]
      # @raise [Devise::Models::Compatibility::NotPersistedError] if record is unsaved
      def update_unique_session_id!(unique_session_id)
        raise Devise::Models::Compatibility::NotPersistedError, 'cannot update a new record' unless persisted?

        update_attribute_without_validatons_or_callbacks(:unique_session_id, unique_session_id).tap do
          Rails.logger.debug { "[devise-security][session_limitable] unique_session_id=#{unique_session_id}" }
        end
      end

      # Should session_limitable be skipped for this instance?
      # @return [Boolean]
      # @return [false] by default. This can be overridden by application logic as necessary.
      def skip_session_limitable?
        false
      end
    end
  end
end
