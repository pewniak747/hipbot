require 'eventmachine'

$connections = []

class ChatServer < EM::Connection
  def post_init
    $connections << self
  end

  def receive_data data
    messages = data.split("\n").map{ |m| "#{m}\n" }.each do |msg|
      sender, room, message = *msg.strip.split(':')
      $connections.reject{|c| c==self}.each do |connection|
        connection.send_data msg
      end
      puts "#{sender}@#{room} > #{message}"
    end
  end
end

EM::run do
  EM::start_server('0.0.0.0', 3001, ChatServer)
end
