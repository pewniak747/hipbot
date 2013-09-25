# encoding: utf-8
module Hipbot
  class Message < Struct.new(:raw_body, :room, :sender)
    include Cache

    attr_accessor :body

    MENTION_REGEXP = /@(\p{Word}++)/.freeze

    def initialize *args
      super
      Hipbot.logger.info("MESSAGE from #{sender} in #{room}")
      self.raw_body = raw_body.force_encoding('UTF-8')
      self.body     = strip_bot_mention
    end

    def for? user
      recipients.include? user.mention
    end

    attr_cache :recipients do
      raw_body.scan(MENTION_REGEXP).flatten.compact.uniq
    end

    attr_cache :mentions do
      recipients.tap{ |r| r.delete(bot_mention) }
    end

    def private?
      room.nil?
    end

    protected

    def bot_mention
      Hipbot.user.mention
    end

    def strip_bot_mention
      raw_body.gsub(/^@#{bot_mention}[^\p{Word}]*/, '')
    end
  end
end
