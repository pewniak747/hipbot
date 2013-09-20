module Hipbot
  class Reaction < Struct.new(:plugin, :options, :block)
    include Cache

    def any_room?
      options[:room] == true
    end

    def anything?
      regexps.blank?
    end

    def anywhere?
      options[:room].nil?
    end

    def condition
      options[:if] || Proc.new{ true }
    end

    def delete
      plugin.reactions.delete(self)
    end

    def desc
      options[:desc]
    end

    def from_all?
      options[:from].blank?
    end

    def global?
      !!options[:global]
    end

    def inspect
      "#<Hipbot::Reaction #{options}>"
    end

    def plugin_name
      plugin.name.demodulize
    end

    def match_with message
      Match.new(self, message)
    end

    def private_message_only?
      options[:room] == false
    end

    def readable_command
      regexps.to_s.gsub(/(?<!\\)(\/|\[|\]|\^|\\z|\$|\\)/, '')
    end

    def regexps
      options[:regexps]
    end

    attr_cache :rooms do
      replace_symbols(options[:room], Hipbot.rooms)
    end

    attr_cache :users do
      replace_symbols(options[:from], Hipbot.teams)
    end

    protected

    def replace_symbols values, replacements_hash
      Array(values).flat_map{ |v| replacements_hash[v] || v }.map(&:to_s)
    end
  end
end
