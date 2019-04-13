# frozen_string_literal: true

require_relative "#{DEVISE_ORM}/session_history"
require 'devise-security/hooks/session_traceable'

module Devise
  module Models
    # SessionTraceable takes care of session trail in every authentication.
    # When a session expires after expiring the +token+, the user
    # will be asked for credentials again, it means, he/she will be redirected
    # to the sign in page.
    module SessionTraceable
      extend ActiveSupport::Concern

      included do
        has_many :session_histories, as: :owner, class_name: session_history_class,
                                     inverse_of: :owner, dependent: :destroy
      end

      def self.required_fields(_klass)
        [:session_history_class, :session_ip_verification]
      end

      # Log user session.
      # @return [true] if session is allowed to log.
      # @return [false] if session isn't allowed to log when already exceeded to `:max_active_sessions`
      #   or session is not valid.
      def log_traceable_session!(options = {})
        token = options[:token] || generate_traceable_token
        opts = options.merge(token: token, last_accessed_at: Time.current.utc)
        opts = session_traceable_condition(opts)

        return false if respond_to?(:allow_limitable_authentication?) && !allow_limitable_authentication?

        session_traceable_adapter.create!(opts) && token
      rescue ActiveRecord::ActiveRecordError
        false
      end

      # Check if +token+ is still valid.
      def accept_traceable_token?(token, options = {})
        opts = { active: true, ip_address: nil }.merge(options)
        opts.delete(:ip_address) unless session_ip_verification
        find_traceable_by_token(token, opts).present?
      end

      # Update the `:last_accessed_at` to current time.
      def update_traceable_token(token)
        record = find_traceable_by_token(token)
        record.last_accessed_at = Time.current.utc
        record.save(validate: false)
      end

      # Expire session matching the +token+ by setting `:active` to false.
      def expire_session_token(token)
        record = find_traceable_by_token(token)
        return unless record

        record.active = false
        record.save(validate: false)
      end

      # Find the first instance, matching +token+, and optional +options+.
      def find_traceable_by_token(token, options = {})
        opts = options.merge(token: token)
        opts = session_traceable_condition(opts)
        session_traceable_adapter.find_first opts
      end

      def session_ip_verification
        self.class.session_ip_verification
      end

      private

      def generate_traceable_token
        loop do
          token = Devise.friendly_token
          break token if find_traceable_by_token(token).blank?
        end
      end

      def session_traceable_adapter
        self.class.session_history_class.constantize.to_adapter
      end

      def session_traceable_condition(options = {})
        options.deep_merge(owner: self)
      end

      class_methods do
        ::Devise::Models.config(self, :session_history_class, :session_ip_verification)
      end
    end
  end
end
