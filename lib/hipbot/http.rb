module Hipbot
  module Http
    class Request < Struct.new(:url, :query, :method)
      DEFAULT_HEADERS     = { 'accept-encoding' => 'gzip, compressed' }.freeze
      CONNECTION_SETTINGS = { connect_timeout: 5, inactivity_timeout: 10 }.freeze
      ERROR_CALLBACK      = ->{ Hipbot.logger.error("HTTP-RESPONSE-ERROR: #{url}") }

      def initialize *args
        super
        Hipbot.logger.info("HTTP-REQUEST: #{url} #{query}")
      end

      def call &success_block
        http.errback(&ERROR_CALLBACK)
        http.callback do
          success(&success_block)
        end unless success_block.nil?
      end

      protected

      def success
        yield Http::Response.new(http)
      rescue => e
        Hipbot.logger.error(e)
        instance_exec(e, &Hipbot.error_handler)
      end

      def http
        @http ||= connection.send(method, query: query.merge(head: DEFAULT_HEADERS))
      end

      def connection
        EM::HttpRequest.new(url, CONNECTION_SETTINGS)
      end
    end

    class Response < Struct.new(:raw_response)
      def initialize *args
        super
        Hipbot.logger.info("HTTP-RESPONSE: #{headers}")
      end

      def body
        raw_response.response
      end

      def code
        raw_response.response_header.status
      end

      def headers
        raw_response.response_header
      end

      def json
        @json ||= JSON.parse(body)
      end
    end
  end
end
