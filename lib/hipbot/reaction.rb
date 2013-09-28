module Hipbot
  class Reaction < Struct.new(:plugin, :options, :block)
    include Cache

    def in_any_room?
      options[:room] == true
    end

    def to_anything?
      regexps.empty?
    end

    def from_anywhere?
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
      options[:from].nil?
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

    def to_private_message?
      options[:room] == false
    end

    attr_cache :readable_command do
      regexps.map(&:source).join(' or ').gsub(/\^|\\z|\$|\\/, '')
    end

    attr_cache :regexps do
      Array(options[:regexps]).map do |regexp|
        Regexp.new(regexp.source, Regexp::IGNORECASE)
      end
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
