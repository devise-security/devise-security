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

      def self.required_fields(_klass)
        %i[unique_session_id max_active_sessions reject_sessions timeout_in]
      end

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

      # Removes old/inactive session if allowed.
      def allow_limitable_authentication?
        # Always fallback to default logic when session_traceable is not supported.
        return true unless devise_modules.include?(:session_traceable)

        opts = session_traceable_condition(active: true)
        return true if max_active_sessions > session_traceable_adapter.find_all(opts).size
        return deactivate_expired_sessions! if reject_sessions?

        opts[:order] = %i[last_accessed_at asc]
        session = session_traceable_adapter.find_first(opts)
        return false unless session

        session.update_attribute_without_validatons_or_callbacks(:active, false)
      end

      # Deactivate expired sessions
      def deactivate_expired_sessions!
        # Always fallback to default logic when session_traceable is not supported.
        return true unless devise_modules.include?(:session_traceable)

        opts = session_traceable_condition(active: true, order: %i[last_accessed_at asc])
        session_traceable_adapter.find_all(opts).any? do |session|
          next unless session.last_accessed_at && timeout_in && session.last_accessed_at <= timeout_in.ago

          session.update_attribute_without_validatons_or_callbacks(:active, false)
        end
      end

      # Maximum number of active sessions
      # @return [Numeric]
      # @return [1] by default. This can be overridden by application logic as necessary.
      def max_active_sessions
        # Always fallback to default logic when session_traceable is not supported.
        return 1 unless devise_modules.include?(:session_traceable)

        self.class.max_active_sessions
      end

      # Reject session when exceeded to allowed number of active sessions
      # @return [Boolean]
      # @return [false] by default. This can be overridden by application logic as necessary.
      def reject_sessions
        # Always fallback to default logic when session_traceable is not supported.
        return false unless devise_modules.include?(:session_traceable)

        self.class.reject_sessions
      end
      alias reject_sessions? reject_sessions

      # Should session_limitable be skipped for this instance?
      # @return [Boolean]
      # @return [false] by default. This can be overridden by application logic as necessary.
      def skip_session_limitable?
        false
      end

      class_methods do
        ::Devise::Models.config(
          self,
          :max_active_sessions,
          :reject_sessions,
          :timeout_in
        )
      end
    end
  end
end
