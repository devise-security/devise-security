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
    #
    # When used together with +:session_traceable+, supports configurable
    # +max_active_sessions+ and automatic eviction of the oldest session.
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

        attrs = { unique_session_id: unique_session_id }
        attrs[:updated_at] = Time.current if respond_to?(:updated_at)
        self.class.where(id: id).update_all(attrs)
        Rails.logger.debug { "[devise-security][session_limitable] unique_session_id=#{unique_session_id}" }
      end

      # Check whether the user is allowed to authenticate based on active session count.
      # When +session_traceable+ is not included, always returns +true+ (original behavior).
      # When +session_traceable+ is included, checks active sessions against +max_active_sessions+.
      #
      # @return [Boolean] true if authentication should be allowed
      def allow_limitable_authentication?
        return true unless devise_modules.include?(:session_traceable)

        active_count = session_histories.where(active: true).count
        return true if active_count < max_active_sessions

        # At capacity — try to make room
        if reject_sessions?
          deactivate_expired_sessions!
        else
          evict_oldest_session!
        end
      end

      # Evict the oldest active session to make room for a new one.
      #
      # @return [Boolean] true if a session was evicted, false otherwise
      def evict_oldest_session!
        return false unless devise_modules.include?(:session_traceable)

        oldest = session_histories.where(active: true).order(last_accessed_at: :asc).first
        return false unless oldest

        oldest.update_attribute_without_validatons_or_callbacks(:active, false)
        true
      end

      # Deactivate sessions that have timed out based on +timeout_in+.
      #
      # @return [Boolean] true if any sessions were deactivated
      def deactivate_expired_sessions!
        return true unless devise_modules.include?(:session_traceable)
        return false unless timeout_in

        cutoff = timeout_in.ago
        expired = session_histories.where(active: true)
                                   .where(last_accessed_at: ..cutoff)
        return false if expired.none?

        expired.each do |session|
          session.update_attribute_without_validatons_or_callbacks(:active, false)
        end
        true
      end

      # Maximum number of active sessions allowed.
      # Without +session_traceable+, always returns 1 (original behavior).
      # Supports +Proc+ values — resolved via +instance_exec+ so the Proc
      # can reference instance state (e.g., +admin?+).
      #
      # @return [Integer]
      def max_active_sessions
        return 1 unless devise_modules.include?(:session_traceable)

        value = self.class.max_active_sessions
        value.is_a?(Proc) ? instance_exec(&value) : value
      end

      # Whether to reject new sessions when at capacity (vs evicting oldest).
      # Without +session_traceable+, always returns false.
      # Supports +Proc+ values — resolved via +instance_exec+.
      #
      # @return [Boolean]
      def reject_sessions
        return false unless devise_modules.include?(:session_traceable)

        value = self.class.reject_sessions
        value.is_a?(Proc) ? instance_exec(&value) : value
      end
      alias reject_sessions? reject_sessions

      # Session timeout duration.
      # Supports +Proc+ values — resolved via +instance_exec+.
      #
      # @return [ActiveSupport::Duration, nil] session timeout duration
      def timeout_in
        value = self.class.timeout_in
        value.is_a?(Proc) ? instance_exec(&value) : value
      end

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
