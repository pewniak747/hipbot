module Hipbot
  class Reaction < Struct.new(:robot, :regexp, :options, :block)
    def match? sender, room, message
      matches?(message) && matches_scope?(message) && matches_sender?(sender)
    end

    def arguments_for message
      processed_message(message).match(regexp)[1..-1]
    end

    def global?
      options[:global]
    end

    def from_all?
      !options[:from]
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

    def matches_scope?(message)
      global? || to_robot?(message)
    end

    def matches_sender?(sender)
      from = options[:from]
      from_all? ||
      from == sender ||
      (from.is_a?(Array) && from.select{|f| f == sender}.size > 0)
    end

    def to_robot? message
      message =~ /^@#{robot.name}.*/
    end
  end
end
