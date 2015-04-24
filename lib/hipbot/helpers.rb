require 'hipbot/helpers/http'

module Hipbot
  module Helpers
    [:get, :post, :put, :delete].each do |method|
      define_method method do |url, query = {}, &block|
        Http::Request.new(url, query, method).call(&block)
      end
      module_function method
    end
  end
end
