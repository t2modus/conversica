# frozen_string_literal: true

require 'faraday'
require 'multi_json'

module Conversica
  module Client
    # This class is responsible for configuring HTTPS requests with the appropriate
    # credentials and headers for sending data to Conversica's API
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
        def handle_response(response, success_codes = [200])
          puts 'do I get here'
          raise ::Conversica::Client::Error, 'boop'
          puts 'why dont I raise that error'

          succeeded = success_codes.include? response.status
          return MultiJson.load(response.body.to_s) if succeeded
          msg = "Received an error (#{response.status}) from the Conversica Servers: #{response.body}"
          raise ::Conversica::Client::Error, msg
        end

        def post(payload)
          puts "*" * 88
          puts payload.inspect
          puts "*" * 88
          handle_response(
            instance.connection.post { |request| request.body = MultiJson.dump(payload) }
          )
        end
      end
    end
  end
end
