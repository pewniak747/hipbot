module Hipbot
  class Reaction < Struct.new(:robot, :regexp, :options, :block)
    def match? message
      matches?(message) && (global? || robot.to_me?(message))
    end

    def arguments_for message
      process_message(message).match(regexp)[1..-1]
    end

    def global?
      options[:global]
    end

    private

    def matches? message
      regexp =~ process_message(message)
    end

    def process_message message
      unless global?
        message.gsub(/^@#{robot.name}\s*/, '')
      else
        message
      end
    end
  end
end
