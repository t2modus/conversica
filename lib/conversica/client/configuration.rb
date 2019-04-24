# frozen_string_literal: true

require 'faraday'
require 'multi_json'

module Conversica
  module Client
    # This class is responsible for configuring HTTP requests with credentials and headers for sending
    # data to Conversica's API
    class Configuration
      include Singleton

      def initialize
        @username = ENV['CONVERSICA_OUTGOING_USERNAME']
        @password = ENV['CONVERSICA_OUTGOING_PASSWORD']
      end

      def connection
        Faraday.new(
          url: 'https://integrations-api.conversica.com/json/',
          headers: {
            'Accept' => 'application/json',
            'Content-Type' => 'application/json'
          }
        ).tap do |connection|
          connection.basic_auth @username, @password
        end
      end

      class << self
        def post(payload)
          instance.connection.post do |request|
            request.body = MultiJson.dump(payload)
          end
        end
      end
    end
  end
end
