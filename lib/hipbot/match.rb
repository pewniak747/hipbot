module Hipbot
  class Match < Struct.new(:reaction, :message)
    include Cache

    def matches?
      matches_scope? && matches_place? && matches_regexp? && matches_sender? && matches_condition?
    end

    def invoke
      Response.new(reaction, message).invoke(reaction_parameters)
    end

    protected

    def reaction_parameters
      reaction.to_anything? ? [message.body] : match_data[1..-1]
    end

    def matches_regexp?
      reaction.to_anything? || !match_data.nil? || reaction.regexps.empty?
    end

    attr_cache :match_data do
      reaction.regexps.inject(nil) do |result, regexp|
        break result if result
        message_text.match(regexp)
      end
    end

    def matches_scope?
      reaction.global? || message.for?(Hipbot.user) || message.private?
    end

    def matches_place?
      reaction.from_anywhere? || (message.room.nil? ? reaction.to_private_message? : matches_room?)
    end

    def matches_room?
      reaction.in_any_room? || reaction.rooms.include?(message.room.name)
    end

    def matches_sender?
      reaction.from_all? || reaction.users.include?(message.sender.name)
    end

    def matches_condition?
      reaction.condition.call(*reaction.condition.parameters.map{ |parameter| message.send(parameter.last) })
    end

    def message_text
      reaction.global? ? message.raw_body : message.body
    end

    class << self
      def invoke_all matches
        matches.each(&:invoke)
      end
    end
  end
end
