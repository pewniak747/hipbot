require 'logger'

module Hipbot
  class Logger < ::Logger
    def add(severity, message = nil, progname = nil, &block)
      msg = message || (block_given? and block.call) || progname
      super(severity, "[#{severity}][#{Time.now}] #{msg}")
    end
  end

  def self.logger
    Hipbot::Bot.instance.logger
  end
end
