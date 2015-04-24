require 'logger'

module Hipbot
  class Logger < ::Logger
    def format_message(severity, timestamp, progname, msg)
      "[#{severity}][#{Time.now}] #{msg}\n"
    end
  end
end
