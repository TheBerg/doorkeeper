# frozen_string_literal: true

module Doorkeeper
  class Config
    # Doorkeeper configuration validator.
    #
    module Validations
      # Validates configuration options to be set properly.
      #
      def validate!
        validate_reuse_access_token_value
        validate_token_reuse_limit
        validate_secret_strategies
        validate_custom_access_token_attributes
      end

      private

      # Determine whether +reuse_access_token+ and a non-restorable
      # +token_secret_strategy+ have both been activated.
      #
      # In that case, disable reuse_access_token value and warn the user.
      def validate_reuse_access_token_value
        strategy = token_secret_strategy
        return if !reuse_access_token || strategy.allows_restoring_secrets?

        ::Rails.logger.warn(
          "[DOORKEEPER] You have configured both reuse_access_token " \
          "AND '#{strategy}' strategy which cannot restore tokens. " \
          "This combination is unsupported. reuse_access_token will be disabled",
        )
        @reuse_access_token = false
      end

      # Validate that the provided strategies are valid for
      # tokens and applications
      def validate_secret_strategies
        token_secret_strategy.validate_for(:token)
        application_secret_strategy.validate_for(:application)
      end

      def validate_token_reuse_limit
        return if !reuse_access_token ||
                  (token_reuse_limit > 0 && token_reuse_limit <= 100)

        ::Rails.logger.warn(
          "[DOORKEEPER] You have configured an invalid value for token_reuse_limit option. " \
          "It will be set to default 100",
        )
        @token_reuse_limit = 100
      end

      # Validate that the access_token and access_grant models
      # both respond to all of the custom attributes
      def validate_custom_access_token_attributes
        return if custom_access_token_attributes.blank?

        unrecognized_attributes = []
        custom_access_token_attributes.each do |attrib|
          [access_token_model, access_grant_model].each do |model|
            next if model.has_attribute?(attrib)

            unrecognized_attributes << attrib
            ::Rails.logger.warn(
              "[DOORKEEPER] #{access_token_model} does not respond to custom attribute '#{attrib}'. " \
              "This custom attribute will be ignored.",
            )
          end
        end

        @custom_access_token_attributes -= unrecognized_attributes
      end
    end
  end
end
