module Hipbot
  class Reaction < Struct.new(:robot, :regexp, :options, :block)
    def match? sender, room, message
      matches?(message) && (global? || to_robot?(message))
    end

    def arguments_for message
      processed_message(message).match(regexp)[1..-1]
    end

    def global?
      options[:global]
    end

    def processed_message message
      unless global?
        message.gsub(/^@#{robot.name}\s*/, '')
      else
        message
      end
    end

    private

    def matches? message
      regexp =~ processed_message(message)
    end

    def to_robot? message
      message =~ /^@#{robot.name}.*/
    end
  end
end
