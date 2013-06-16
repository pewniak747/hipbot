module Hipbot
  class Match < Struct.new(:reaction, :message)
    def matches?
      matches_regexp? && matches_scope? && matches_sender? && matches_place?
    end

    def invoke
      Response.new(reaction, message).invoke(params)
    end

    protected

    def params
      reaction.anything? ? [message.body] : regexp_match[1..-1]
    end

    def matches_regexp?
      reaction.anything? || regexp_match.present?
    end

    def regexp_match
      @regexp_match ||= reaction.regexps.inject(nil) do |result, regexp|
        break result if result
        message_text.match(regexp)
      end
    end

    def matches_scope?
      reaction.global? || message.for?(Hipbot.user) || message.private?
    end

    def matches_place?
      reaction.anywhere? || (message.room.present? ? matches_room? : reaction.private_message_only?)
    end

    def matches_room?
      reaction.any_room? || reaction.rooms.include?(message.room.name)
    end

    def matches_sender?
      reaction.from_all? || reaction.users.include?(message.sender.name)
    end

    def message_text
      reaction.global? ? message.raw_body : message.body
    end
  end
end
