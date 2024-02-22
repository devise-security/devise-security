# frozen_string_literal: true

require_relative "#{DEVISE_ORM}/session_history"
require 'devise-security/hooks/session_traceable'

module Devise
  module Models
    # The `SessionTraceable` module ensures the management of session trails during authentication.
    # When a session expires due to the expiration of the associated token,
    # the user is prompted to re-enter credentials. Consequently, they are redirected
    # to the sign-in page to establish a new session.
    module SessionTraceable
      extend ActiveSupport::Concern
      include Devise::Models::Compatibility

      included do
        has_many :session_histories, as: :owner, class_name: session_history_class,
                                     inverse_of: :owner, dependent: :destroy
      end

      # Returns the required fields for this module.
      #
      # @param _klass [Class] The class to which this module is included.
      # @return [Array<Symbol>] The required fields for this module.
      def self.required_fields(_klass)
        %i[session_history_class session_ip_verification]
      end

      # Log user session.
      #
      # @param options [Hash] The options for logging the session.
      # @option options [String] :token The session history token.
      # @return [String] session history token if allowed to log.
      # @return [NilClass] if session isn't allowed to log when already exceeded to `:max_active_sessions`
      #   or session is not valid.
      def log_traceable_session!(options = {})
        return if devise_modules.include?(:session_limitable) && !allow_limitable_authentication?

        token = options[:token] || generate_traceable_token
        opts = options.merge(token: token, last_accessed_at: Time.current.utc)
        opts = session_traceable_condition(opts)

        session_traceable_adapter.create!(opts) && token
      rescue ActiveRecord::ActiveRecordError
        # Return nothing if the session couldn't be saved.
      end

      # Check if +token+ is still valid.
      #
      # @param token [String] The session history token.
      # @param options [Hash] The options for checking the token.
      # @option options [Boolean] :active Whether the session is active or not.
      # @option options [String] :ip_address The IP address associated with the session.
      # @return [Boolean] true if the token is still valid, false otherwise.
      def accept_traceable_token?(token, options = {})
        opts = { active: true, ip_address: nil }.merge(options)
        opts.delete(:ip_address) unless session_ip_verification
        find_traceable_by_token(token, opts).present?
      end

      # Update the `:last_accessed_at` to current time.
      #
      # @param token [String] The session history token.
      def update_traceable_token(token)
        record = find_traceable_by_token(token)
        record.update_attribute_without_validatons_or_callbacks(:last_accessed_at, Time.current.utc)
      end

      # Expire session matching the +token+ by setting `:active` to false.
      #
      # @param token [String] The session history token.
      def expire_session_token(token)
        session = find_traceable_by_token(token)
        return unless session

        session.update_attribute_without_validatons_or_callbacks(:active, false)
      end

      # Find the first instance, matching +token+, and optional +options+.
      #
      # @param token [String] The session history token.
      # @param options [Hash] The options for finding the session.
      # @option options [Boolean] :active Whether the session is active or not.
      # @option options [String] :ip_address The IP address associated with the session.
      # @return [Object] The first instance matching the token and options.
      def find_traceable_by_token(token, options = {})
        opts = options.merge(token: token)
        opts = session_traceable_condition(opts)
        session_traceable_adapter.find_first opts
      end

      # Restrict session token to IP address.
      #
      # @return [Boolean] true by default.
      #   This can be overridden by application logic as necessary.
      def session_ip_verification
        self.class.session_ip_verification
      end

      # Should session_traceable be skipped for this instance?
      #
      # @return [Boolean] false by default.
      #   This can be overridden by application logic as necessary.
      def skip_session_traceable?
        false
      end

      private

      # Generates a unique traceable token.
      #
      # @return [String] The generated traceable or session history token.
      def generate_traceable_token
        loop do
          token = Devise.friendly_token
          break token if find_traceable_by_token(token).blank?
        end
      end

      # Returns the session traceable adapter.
      #
      # @raise [RuntimeError] if the session history class does not include Devise::Models::Compatibility.
      # @return [Object] The session traceable adapter.
      def session_traceable_adapter
        raise "#{self.class.session_history_class} does not include Devise::Models::Compatibility" unless self.class.session_history_class.constantize.include?(Devise::Models::Compatibility)

        self.class.session_history_class.constantize.to_adapter
      end

      # Returns the session traceable condition.
      #
      # @param options [Hash] The options for the session traceable condition.
      # @return [Hash] The session traceable condition.
      def session_traceable_condition(options = {})
        options.deep_merge(owner: self)
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
