# encoding: utf-8
module Hipbot
  module Http
    class Request < Struct.new(:url, :params, :method)
      DEFAULT_HEADERS     = { 'accept-encoding' => 'gzip, compressed' }.freeze
      CONNECTION_SETTINGS = { connect_timeout: 5, inactivity_timeout: 10 }.freeze
      ERROR_CALLBACK      = ->(error){ Hipbot.logger.error(error) }

      def initialize *args
        super
        self.params ||= {}
        self.params = params.has_key?(:query) ? params : { query: params }
        self.params = { head: DEFAULT_HEADERS }.merge(params)
        Hipbot.logger.info("HTTP-REQUEST: #{url} #{params}")
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
        instance_exec(e, &Hipbot.exception_handler)
      end

      def http options = {}
        @http ||= connection.send(method, params.merge(options))
      end

      def connection
        @connection ||= EM::HttpRequest.new(url, CONNECTION_SETTINGS)
      end
    end

    class Response < Struct.new(:raw_response)
      def initialize *args
        super
        Hipbot.logger.debug("HTTP-RESPONSE: #{body}")
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
        @json ||= JSON.parse(body) || {}
      end
    end
  end
end
