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

    def reaction_sets
      defined_reaction_sets + default_reaction_sets
    end

    def defined_reaction_sets
      reactables.map(&:reactions)
    end

    def default_reaction_sets
      # Each default reaction is alone in its own reaction set
      reactables.flat_map(&:default_reactions).map { |r| [r] }
    end

    def presence_reaction_sets
      reactables.map(&:presence_reactions)
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
