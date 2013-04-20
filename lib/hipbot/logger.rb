require 'logger'

module Hipbot
  class Logger < ::Logger
    def add(severity, message = nil, progname = nil, &block)
      msg = message || (block_given? and block.call) || progname
      severity_name = { 0 => "DEBUG", 1 => "INFO", 2 => "WARN", 3 => "ERROR", 4 => "FATAL", 5 => "UNKNOWN" }[severity]
      super(severity, "[#{severity_name}][#{Time.now}] #{msg}")
    end
  end

  def self.logger
    Hipbot::Bot.instance.logger
  end
end
