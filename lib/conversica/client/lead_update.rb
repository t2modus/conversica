# frozen_string_literal: true

module Conversica
  module Client
    # This class is used to represent an instance of a lead update that will be posted back to our servers by
    # conversica
    class LeadUpdate
      extend AttributesAccessors

      PERMITTED_COLUMNS = %w[
        api_version client_id date_added discovered_phone1 do_not_email first_message_date hot_lead hot_lead_date id
        last_message_date last_response_date
      ].freeze

      DATE_COLUMNS = %w[
        date_added first_message_date hot_lead_date last_message_date last_response_date
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
        DATE_COLUMNS.each do |c|
          self.attributes[c] = DateTime.rfc3339(self.attributes[c]).to_time unless self.attributes[c].blank?
        end
        # rubocop:enable Style/DateTime
      end
    end
  end
end
