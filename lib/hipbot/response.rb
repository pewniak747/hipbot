module Hipbot
  class Response < Struct.new(:bot, :reaction, :room, :message)
    delegate :sender, :recipients, :body, :to => :message

    def initialize bot, reaction, room, message
      super
      extend(bot.helpers)
    end

    def invoke arguments
      instance_exec(*arguments, &reaction.block)
    end

    private

    def reply string, room = self.room
      return bot.send_to_user(sender, string) if room.nil?
      bot.send_to_room(room, string)
    end

    [:get, :post, :put, :delete].each do |http_verb|
      define_method http_verb do |url, query = {}, &block|
        http = ::EM::HttpRequest.new(url).send(http_verb, :query => query)
        http.callback { block.call(::Hipbot::HttpResponse.new(http)) if block }
      end
    end
  end
end
