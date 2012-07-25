module Hipbot
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
  end
end
