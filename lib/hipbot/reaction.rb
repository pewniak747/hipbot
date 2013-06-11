module Hipbot
  class Reaction < Struct.new(:klass, :options, :block)

    def invoke sender, room, message
      message   = message_for(message, sender)
      arguments = arguments_for(message)
      Response.new(self, room, message).invoke(arguments)
    end

    def match? sender, room, message
      message = message_for(message, sender)
      matches_regexp?(message) && matches_scope?(room, message) && matches_sender?(message) && matches_room?(room)
    end

    def inspect
      "#<Hipbot::Reaction #{options}>"
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
      options[:regexps].find{ |regexp| regexp =~ (global? ? message.raw_body : message.body) }
    end

    def matches_scope?(room, message)
      global? || message.for?(Hipbot.bot) || room.nil?
    end

    def matches_room?(room)
      if options[:room].nil?
        true
      elsif room.present?
        options[:room] == true || rooms.include?(room.name)
      else
        options[:room] == false
      end
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
      @rooms ||= Array(options[:room]).flat_map{ |v| Hipbot.rooms[v].presence || [v] }
    end

    def users
      @users ||= Array(options[:from]).flat_map{ |v| Hipbot.teams[v].presence || [v] }
    end
  end
end
