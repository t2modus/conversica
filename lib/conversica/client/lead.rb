# frozen_string_literal: true

module Conversica
  module Client
    # This class is responsible for representing conversica lead objects to be sent to the api
    class Lead
      extend AttributesAccessors

      PERMITTED_COLUMNS = %w[
        address alt_email api_version appointment_date appointment_status bdc_rep_id bdc_rep_email bdc_rep_name
        cell_phone city client_id conversation_id date email first_name home_email home_phone id last_name
        lead_source lead_status lead_type make model opt_out rep_id rep_email rep_name service_rep_id
        service_rep_email service_rep_name sms_opt_out state skip_to_followup stop_messaging vin work_email
        work_phone year zip
      ].freeze
      REQUIRED_ATTRIBUTES = %w[
        api_version bdc_rep_email bdc_rep_name conversation_id email first_name id lead_source lead_status
        year make model rep_email rep_name
      ].freeze
      BOOLEAN_COLUMNS = %w[stop_messaging skip_to_followup opt_out sms_opt_out].freeze
      DATE_COLUMNS = %w[date appointment_date].freeze

      define_attr_accessors_for_attributes

      attr_accessor :attributes, :errors

      def initialize(params)
        self.attributes = params.with_indifferent_access
                                .slice(*PERMITTED_COLUMNS)
                                .merge(api_version: ENV['CONVERSICA_API_VERSION'])
        self.errors = []
      end

      def valid?
        self.validate_types
        self.validate_dates
        self.validate_required
        self.errors.count.zero?
      end

      def validate_types
        PERMITTED_COLUMNS.each do |k|
          permitted_classes, error = if BOOLEAN_COLUMNS.include?(k)
                                       [
                                         [NilClass, TrueClass, FalseClass],
                                         "#{k} must be a boolean value or null"
                                       ]
                                     elsif DATE_COLUMNS.include?(k)
                                       [
                                         [NilClass, Date, Time, String],
                                         "#{k} must be null or a valid date, time, or parsable string object"
                                       ]
                                     else
                                       [
                                         [NilClass, Integer, String],
                                         "#{k} must be null, integer, or a string"
                                       ]
                                     end
          # We actually really truly do need the case equality operator here to determine if
          # the attribute is an instance of a permitted class
          # To do this, we must make sure that the class is FIRST, since
          # Class === instance_of_class is true, but instance_of_class === Class is not
          # rubocop:disable Style/CaseEquality
          self.errors << error unless permitted_classes.any? { |c| c === self.attributes[k] }
          # rubocop:enable Style/CaseEquality
        end
      end

      def validate_dates
        dates = self.attributes.slice(*DATE_COLUMNS).compact
        return if dates.empty?
        dates.each do |key, val|
          self.attributes[key] = val.to_datetime.rfc3339
        rescue ArgumentError
          self.errors << "#{key} is not a valid parsable date string, value passed: #{val.inspect}"
        end
      end

      def validate_required
        REQUIRED_ATTRIBUTES.each do |k|
          self.errors << "#{k} is required" if self.attributes[k].blank?
        end
      end

      # I am perhaps prouder of this method name than I should be
      def conversicate
        hash = self.attributes.dup

        # Apparently for conversica:
        # 1) they do not like to receive nil values so we need to remove the nils
        # 2) we also need to convert integers into strings
        hash.reject! { |_k, v| v.nil? }
        hash.transform_values! { |v| v = v.to_s if v.is_a?(Integer) }

        hash.transform_keys { |k| k.camelize(:lower) }
      end

      class << self
        def create(options)
          lead = self.new(options)
          if lead.valid?
            Configuration.post(lead.conversicate)
          else
            raise ::Conversica::Client::Error, lead.errors.join(', ')
          end
        end
      end
    end
  end
end
