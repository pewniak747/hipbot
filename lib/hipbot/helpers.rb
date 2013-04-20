module Hipbot
  module Helpers
    [:get, :post, :put, :delete].each do |http_verb|
      define_method http_verb do |url, query = {}, &block|
        Hipbot.logger.info("HTTP-REQUEST: #{url} #{query}")
        query.merge!({ :head => {'accept-encoding' => 'gzip, compressed'} })
        conn = ::EM::HttpRequest.new(url, :connect_timeout => 5, :inactivity_timeout => 10)
        http = conn.send(http_verb, :query => query)
        http.callback do
          response = HttpResponse.new(http)
          Hipbot.logger.info("HTTP-RESPONSE: #{response}")
          block.call(response)
        end if block.present?
        http.errback do
          Hipbot.logger.error("HTTP-RESPONSE-ERROR: #{url}")
        end
      end

      module_function http_verb
    end

    class HttpResponse < Struct.new(:raw_response)
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
        @json ||= JSON.parse(body) rescue {}
      end
    end
  end
end
