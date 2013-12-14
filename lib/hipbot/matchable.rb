module Hipbot
  module Matchable
    def react sender, room, body
      message = Message.new(body, room, sender)
      matches = set_matches(reaction_sets, message)
      Match.invoke_all(matches)
    end

    def react_to_presence sender, status, room
      presence = Presence.new(sender, status, room)
      matches  = set_matches(presence_reaction_sets, presence)
      Match.invoke_all(matches)
    end

    def reactions
      reaction_sets.flatten
    end

    protected

    def reactables
      plugins.map(&:class)
    end

    def presence_reaction_sets
      reactables.map(&:presence_reactions)
    end

    def reaction_sets
      reactables.each_with_object([]) do |reactable, array|
        array.unshift(reactable.reactions)
        array.push(reactable.default_reactions)
      end
    end

    def set_matches sets, message
      sets.each do |reactions|
        matches = reactions_matches(message, reactions)
        return matches if matches.any?
      end
      []
    end

    def reactions_matches matchable, reactions
      reactions.map{ |reaction| reaction.match_with(matchable) }.select(&:matches?)
    end
  end
end
