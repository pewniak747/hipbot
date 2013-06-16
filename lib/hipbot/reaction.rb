module Hipbot
  class Reaction < Struct.new(:klass, :options, :block)
    def match_with message
      Match.new(self, message)
    end

    def inspect
      "#<Hipbot::Reaction #{options}>"
    end

    def regexps
      options[:regexps]
    end

    def anywhere?
      options[:room].nil?
    end

    def any_room?
      options[:room] == true
    end

    def private_message_only?
      options[:room] == false
    end

    def global?
      !!options[:global]
    end

    def from_all?
      options[:from].blank?
    end

    def anything?
      regexps.blank?
    end

    def users
      replace_symbols options[:from], Hipbot.teams
    end

    def rooms
      replace_symbols options[:room], Hipbot.rooms
    end

    protected

    def replace_symbols values, replacements_hash
      Array(values).flat_map{ |v| replacements_hash[v].presence || v.to_s }
    end
  end
end
