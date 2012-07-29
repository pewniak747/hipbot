module Hipbot
  class Response < Struct.new(:bot, :reaction, :room, :message)
    delegate :sender, :recipients, :body, :to => :message

    def invoke arguments
      instance_exec(*arguments, &reaction.block)
    end

    private

    def reply string, room = self.room
      bot.reply(room.name, string)
    end

    [:get, :post, :put, :delete].each do |http_verb|
      define_method http_verb do |url, query={}, &block|
        http = ::EM::HttpRequest.new(url).send(http_verb, :query => query)
        http.callback { block.call(::Hipbot::HttpResponse.new(http)) if block }
      end
    end

  end
end
