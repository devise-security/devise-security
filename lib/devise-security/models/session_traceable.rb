# frozen_string_literal: true

require_relative "#{DEVISE_ORM}/session_history"
require 'devise-security/hooks/session_traceable'

module Devise
  module Models
    # SessionTraceable tracks session history during authentication.
    # Each login creates a +SessionHistory+ record with token, IP, user agent,
    # and last access time. Sessions are validated on each request and expired
    # on sign out.
    #
    # Can be used standalone (session tracking only) or with +:session_limitable+
    # for configurable concurrent session limits.
    module SessionTraceable
      extend ActiveSupport::Concern
      include Devise::Models::Compatibility

      included do
        has_many :session_histories, as: :owner, class_name: session_history_class,
                                     inverse_of: :owner, dependent: :destroy
      end

      # @param _klass [Class]
      # @return [Array<Symbol>] required database fields
      def self.required_fields(_klass)
        %i[session_history_class session_ip_verification]
      end

      # Create a session history record for a new login.
      # When +:session_limitable+ is also included, checks +allow_limitable_authentication?+
      # before creating the record.
      #
      # @param options [Hash]
      # @option options [String] :ip_address client IP address
      # @option options [String] :user_agent client user agent string
      # @option options [String] :token optional pre-generated token
      # @return [String] the session token if created successfully
      # @return [nil] if the session was rejected or couldn't be saved
      def log_traceable_session!(options = {})
        return if devise_modules.include?(:session_limitable) && !allow_limitable_authentication?

        token = options[:token] || generate_traceable_token
        attrs = options.except(:token).merge(
          token: token,
          last_accessed_at: Time.current.utc,
          owner: self
        )

        session_history_class.create!(attrs) && token
      rescue ActiveRecord::ActiveRecordError
        nil
      rescue StandardError => e
        raise unless defined?(Mongoid) && e.is_a?(Mongoid::Errors::MongoidError)

        nil
      end

      # Check if a session token is still valid (active and optionally IP-matched).
      #
      # @param token [String] the session token to validate
      # @param options [Hash]
      # @option options [String] :ip_address IP to verify against (when +session_ip_verification+ enabled)
      # @return [Boolean]
      def accept_traceable_token?(token, options = {})
        conditions = { active: true }
        conditions[:ip_address] = options[:ip_address] if session_ip_verification
        find_traceable_by_token(token, conditions).present?
      end

      # Update the last_accessed_at timestamp for a session.
      #
      # @param token [String] the session token
      # @return [Boolean, nil] result of the update, nil if token not found
      def update_traceable_token!(token)
        record = find_traceable_by_token(token)
        return unless record

        record.update_attribute_without_validatons_or_callbacks(:last_accessed_at, Time.current.utc)
      end

      # Expire (deactivate) a session by token.
      #
      # @param token [String] the session token
      # @return [Boolean, nil] result of the update, nil if token not found
      def expire_session_token!(token)
        session = find_traceable_by_token(token)
        return unless session

        session.update_attribute_without_validatons_or_callbacks(:active, false)
      end

      # @deprecated Use {#update_traceable_token!} instead
      alias update_traceable_token update_traceable_token!
      # @deprecated Use {#expire_session_token!} instead
      alias expire_session_token expire_session_token!

      # Find a session history record by token.
      #
      # @param token [String]
      # @param conditions [Hash] additional query conditions
      # @return [SessionHistory, nil]
      def find_traceable_by_token(token, conditions = {})
        session_histories.where(conditions.merge(token: token)).first
      end

      # Whether session tokens are restricted to the originating IP address.
      #
      # @return [Boolean] true by default
      delegate :session_ip_verification, to: :class

      # Should session_traceable be skipped for this instance?
      #
      # @return [Boolean] false by default
      def skip_session_traceable?
        false
      end

      private

      # Generate a unique session token.
      #
      # @return [String]
      def generate_traceable_token
        loop do
          token = Devise.friendly_token
          break token unless session_histories.exists?(token: token)
        end
      end

      # @return [Class] the session history model class
      def session_history_class
        self.class.session_history_class.constantize
      end

      class_methods do
        ::Devise::Models.config(
          self,
          :session_history_class,
          :session_ip_verification
        )
      end
    end
  end
end
