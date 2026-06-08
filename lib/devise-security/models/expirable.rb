# frozen_string_literal: true

require_relative 'compatibility'
require 'devise-security/hooks/expirable'

module Devise
  module Models
    # Deactivate the account after a configurable amount of time.  To be able to
    # tell, it tracks activity about your account with the following columns:
    #
    # * last_activity_at - A timestamp updated when the user requests a page (only signed in)
    #
    # == Options
    # +:expire_after+ - Time interval to expire accounts after
    #
    # == Additions
    # Best used with two cron jobs. One for expiring accounts after inactivity,
    # and another, that deletes accounts, which have expired for a given amount
    # of time (for example 90 days).
    #
    module Expirable
      extend ActiveSupport::Concern
      include Devise::Models::Compatibility

      def self.required_fields(_klass)
        %i[last_activity_at expired_at]
      end

      # Updates +last_activity_at+, called from a Warden::Manager.after_set_user hook.
      #
      # When {#last_activity_update_interval} is set to a positive duration,
      # the write is skipped if +last_activity_at+ was updated less than that
      # interval ago. This avoids unnecessary DB writes on high-frequency
      # authenticated requests (see upstream issue #494).
      #
      # @return [void]
      def update_last_activity!
        interval = last_activity_update_interval

        return if interval&.positive? && last_activity_at.present? && last_activity_at > interval.ago

        update_attribute_without_validatons_or_callbacks(:last_activity_at, Time.now.utc)
      end

      # Minimum interval between +last_activity_at+ DB writes.
      # Override in your model for per-record dynamic throttling.
      #
      # @return [ActiveSupport::Duration, Integer, nil]
      delegate :last_activity_update_interval, to: :class

      # Tells if the account has expired
      #
      # @return [bool]
      def expired?
        # expired_at set (manually, via cron, etc.)
        return expired_at < Time.now.utc unless expired_at.nil?

        # if it is not set, check the last activity against configured expire_after time range
        return last_activity_at < expire_after.ago unless last_activity_at.nil?

        # if last_activity_at is nil as well, the user has to be 'fresh' and is therefore not expired
        false
      end

      # Expire an account. This is for cron jobs and manually expiring of accounts.
      #
      # @example
      #   User.expire!
      #   User.expire! 1.week.from_now
      # @note +expired_at+ can be in the future as well
      def expire!(at = Time.now.utc)
        self.expired_at = at
        save(validate: false)
      end

      # Overwrites active_for_authentication? from Devise::Models::Activatable
      # for verifying whether a user is active to sign in or not. If the account
      # is expired, it should never be allowed.
      #
      # @return [bool]
      def active_for_authentication?
        super && !expired?
      end

      # The message sym, if {#active_for_authentication?} returns +false+. E.g. needed
      # for i18n.
      #
      # @return [Symbol] +:expired+ if the account is expired, otherwise delegates to +super+
      def inactive_message
        expired? ? :expired : super
      end

      # Time interval after which accounts are considered expired.
      # Override in your model for per-record dynamic expiry.
      #
      # @return [ActiveSupport::Duration]
      delegate :expire_after, to: :class

      # Time interval after which expired accounts are deleted.
      # Override in your model for per-record dynamic behavior.
      #
      # @return [ActiveSupport::Duration]
      delegate :delete_expired_after, to: :class

      class_methods do
        ::Devise::Models.config(self, :expire_after, :delete_expired_after, :last_activity_update_interval)

        # Sample method for daily cron to mark expired entries.
        #
        # @example You can overide this in your +resource+ model
        #   def self.mark_expired
        #     puts 'overwritten mark_expired'
        #   end
        def mark_expired
          all.each do |u|
            u.expire! if u.expired? && u.expired_at.nil?
          end
        end

        # Scope to collect all users who have been expired for at least +time+.
        # Includes both manually expired users (via +expired_at+) and
        # inactivity-expired users (via +last_activity_at+ older than
        # +expire_after + time+).
        #
        # @param time [ActiveSupport::Duration] minimum duration since expiry
        #   (defaults to +delete_expired_after+)
        # @return [ActiveRecord::Relation]
        def expired_for(time = delete_expired_after)
          cutoff = time.ago
          inactivity_cutoff = (expire_after + time).ago

          if DEVISE_ORM == :active_record
            where(
              'expired_at < :cutoff OR ' \
              '(expired_at IS NULL AND last_activity_at IS NOT NULL AND last_activity_at < :inactivity_cutoff)',
              cutoff: cutoff,
              inactivity_cutoff: inactivity_cutoff
            )
          else
            # Mongoid: use hash-based criteria
            any_of(
              { expired_at: { :$lt => cutoff } },
              { expired_at: nil, last_activity_at: { :$ne => nil, :$lt => inactivity_cutoff } }
            )
          end
        end

        # Sample method for daily cron to delete all expired entries after a
        # given amount of +time+.
        #
        # In your overwritten method you can "blank out" the object instead of
        # deleting it.
        #
        # *Word of warning*: You have to handle the dependent method
        # on the +resource+ relations (+:destroy+ or +:nullify+) and catch this
        # behavior (see  http://api.rubyonrails.org/classes/ActiveRecord/Associations/ClassMethods.html#label-Deleting+from+associations).
        #
        # @example
        #   Resource.delete_all_expired_for 90.days
        # @example You can overide this in your +resource+ model
        #   def self.delete_all_expired_for(time = 90.days)
        #     puts 'overwritten delete call'
        #   end
        # @example Overwritten version to blank out the object.
        #   def self.delete_all_expired_for(time = 90.days)
        #     expired_for(time).each do |u|
        #       u.update first_name: nil, last_name: nil
        #     end
        #   end
        def delete_all_expired_for(time)
          expired_for(time).delete_all
        end

        # Version of {#delete_all_expired_for} without arguments (uses
        # configured +delete_expired_after+ default value).
        # @see #delete_all_expired_for
        def delete_all_expired
          delete_all_expired_for(delete_expired_after)
        end
      end
    end
  end
end
