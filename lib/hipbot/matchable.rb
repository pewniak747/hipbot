module Hipbot
  module Matchable
    def react sender, room, body
      message = Message.new(body, room, sender)
      matches = message_matches(message)
      Match.invoke_all(matches)
    end

    def reactions
      reactions_sets.flatten
    end

    protected

    def reactables
      plugins.map(&:class)
    end

    def reaction_sets
      reactables.flat_map do |reactable|
        [reactable.reactions, reactable.default_reactions]
      end
    end

    def message_matches message
      reaction_sets.each do |reactions|
        matches = reactions_matches(message, reactions)
        return matches if matches.any?
      end
      []
    end

    def reactions_matches message, reactions
      reactions.map{ |reaction| reaction.match_with(message) }.select(&:matches?)
    end
  end
end
