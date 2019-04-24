# frozen_string_literal: true

module Conversica
  module Client
    # this class is used to represent a message that gets posted back to our server by conversica
    class Message
      extend AttributesAccessors

      PERMITTED_COLUMNS = %w[
        action api_version body client_id date id subject
      ].freeze

      define_attr_accessors_for_attributes

      attr_accessor :attributes

      def initialize(params)
        self.attributes = params.with_indifferent_access
                                .transform_keys(&:underscore)
                                .slice(*PERMITTED_COLUMNS)
        # I need to use date time rather than date or time initially because it has the handy parsing method
        # that I need. So instead, I'll just parse it then immediately convert it to an instance of time.
        # rubocop:disable Style/DateTime
        self.date = DateTime.rfc3339(self.date).to_time unless self.date.blank?
        # rubocop:enable Style/DateTime
      end
    end
  end
end
