# frozen_string_literal: true

module Devise
  module Models
    # SessionLimited ensures, that there is only one session usable per account at once.
    # If someone logs in, and some other is logging in with the same credentials,
    # the session from the first one is invalidated and not usable anymore.
    # The first one is redirected to the sign page with a message, telling that
    # someone used his credentials to sign in.
    module SessionLimitable
      extend ActiveSupport::Concern

      def self.required_fields(_klass)
        [:session_history_class, :max_active_sessions, :timeout_in, :limit_sessions]
      end

      # Removes old/inactive session if allowed.
      def allow_limitable_authentication?
        opts = session_limitable_condition(active: true)
        return true if max_active_sessions > session_limitable_adapter.find_all(opts).size
        return deactivate_timeout_sessions! if limit_sessions

        opts[:order] = [:last_accessed_at, :asc]
        session = session_limitable_adapter.find_first(opts)
        session.active = false
        session.save(validate: false)
      end

      def max_active_sessions
        self.class.max_active_sessions
      end

      def limit_sessions
        self.class.limit_sessions
      end

      private

      def deactivate_timeout_sessions!
        opts = session_limitable_condition(active: true, order: [:last_accessed_at, :asc])
        session_limitable_adapter.find_all(opts).any? do |session|
          next unless session.last_accessed_at && timeout_in && session.last_accessed_at <= timeout_in.ago

          session.active = false
          session.save(validate: false)
        end
      end

      def session_limitable_adapter
        self.class.session_history_class.constantize.to_adapter
      end

      def session_limitable_condition(options = {})
        options.deep_merge(owner: self)
      end

      class_methods do
        ::Devise::Models.config self,
                                :session_history_class,
                                :max_active_sessions,
                                :timeout_in,
                                :limit_sessions
      end
    end
  end
end
