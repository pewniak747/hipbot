module Hipbot
  class Reaction < Struct.new(:robot, :regexp, :options, :block)

    def invoke sender, room, message
      message = message_for(message, sender)
      arguments = arguments_for(message)
      Response.new(robot, self, room, message).invoke(arguments)
    end

    def match? sender, room, message
      message = message_for(message, sender)
      matches_regexp?(message) && matches_scope?(message) && matches_sender?(message) && matches_room?(room)
    end

    private

    def message_for message, sender
      Message.new(message, sender)
    end

    def arguments_for message
      message.body.match(regexp)[1..-1]
    end

    def matches_regexp?(message)
      regexp =~ message.body
    end

    def matches_room?(room)
      !options[:room] || options[:room].include?(room)
    end

    def matches_scope?(message)
      global? || message.for?(robot)
    end

    def matches_sender?(message)
      from_all? || Array(options[:from]).include?(message.sender)
    end

    def global?
      options[:global]
    end

    def from_all?
      !options[:from]
    end

  end
end
