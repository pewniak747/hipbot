module Hipbot
class Response < Struct.new(:bot, :reaction, :room, :message_object)

  def invoke arguments
    instance_exec(*arguments, &reaction.block)
  end

  private
  def reply string
    bot.reply(room, string)
  end

  [:get, :post, :put, :delete].each do |http_verb|
    define_method http_verb do |url, query={}, &block|
      http = ::EM::HttpRequest.new(url).send(http_verb, :query => query)
      http.callback { block.call(http) if block }
    end
  end

  def message
    message_object.body
  end

  def sender
    message_object.sender
  end

  def recipients
    message_object.recipients
  end
end
end
