module Hipbot
  class Reaction < Struct.new(:bot, :regexps, :options, :block)

    def invoke sender, room, message
      message   = message_for(message, sender)
      arguments = arguments_for(message)
      Response.new(bot, self, room, message).invoke(arguments)
    end

    def match? sender, room, message
      message = message_for(message, sender)
      matches_regexp?(message) && matches_scope?(room, message) && matches_sender?(message) && matches_room?(room)
    end

    protected

    def message_for message, sender
      Message.new(message, sender)
    end

    def arguments_for message
      (global? ? message.raw_body : message.body).match(matching_regexp(message))[1..-1]
    end

    def matches_regexp?(message)
      matching_regexp(message).present?
    end

    def matching_regexp(message)
      regexps.find{ |regexp| regexp =~ (global? ? message.raw_body : message.body) }
    end

    def matches_scope?(room, message)
      global? || message.for?(bot) || room.nil?
    end

    def matches_room?(room)
      !!options[:room] ? room.present? && rooms.include?(room.name) : true
    end

    def matches_sender?(message)
      from_all? || users.include?(message.sender.name)
    end

    def global?
      !!options[:global]
    end

    def from_all?
      options[:from].blank?
    end

    def rooms
      Array(options[:room]).flat_map{ |v| bot.rooms[v].presence || [v] }
    end

    def users
      Array(options[:from]).flat_map{ |v| bot.teams[v].presence || [v] }
    end
  end
end
