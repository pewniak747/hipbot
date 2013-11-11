module Hipbot
  class Response < Struct.new(:reaction, :message)
    include Helpers

    delegate :sender, :room, to: :message
    delegate :bot, to: Hipbot

    def initialize *_
      super
      Hipbot.logger.info("RESPONSE WITH #{reaction.inspect}")
    end

    def invoke arguments
      handle_answer do
        instance_exec(*arguments, &reaction.block)
      end
    rescue Exception => e
      instance_exec(e, &Hipbot.error_handler)
    end

    def reply message, room = self.room
      (room || sender).send_message(message)
    end

    protected

    def handle_answer
      answer = catch(:error){ yield }
      reply(answer) if answer.is_a?(String) && !answer.blank?
    end

    def method_missing method, *args, &block
      plugin.send(method, *args, &block)
    end

    def plugin
      reaction.plugin.with_response(self)
    end
  end
end
