module Hipbot
  class Reaction < Struct.new(:robot, :regexps, :options, :block)

    def invoke sender, room, message
      message = message_for(message, sender)
      arguments = arguments_for(message)
      Response.new(robot, self, room, message).invoke(arguments)
    end

    def match? sender, room, message
      message = message_for(message, sender)
      matches_regexp?(message) && matches_scope?(room, message) && matches_sender?(message) && matches_room?(room)
    end

    private

    def message_for message, sender
      Message.new(message, sender)
    end

    def arguments_for message
      message.body.match(matching_regexp(message))[1..-1]
    end

    def matches_regexp?(message)
      matching_regexp(message).present?
    end

    def matches_room?(room)
      !options[:room] || Array(options[:room]).include?(room.name) || room.nil?
    end

    def matches_scope?(room, message)
      global? || message.for?(robot) || room.nil?
    end

    def matches_sender?(message)
      from_all? || Array(options[:from]).include?(message.sender)
    end

    def matching_regexp(message)
      regexps.find { |regexp| regexp =~ message.body }
    end

    def global?
      options[:global]
    end

    def from_all?
      !options[:from]
    end
  end
end
