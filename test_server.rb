require 'eventmachine'

$connections = []

class ChatServer < EM::Connection
  def post_init
    $connections << self
  end

  def receive_data data
    sender, room, message = *data.strip.split(':')
    $connections.reject{|c| c==self}.each do |connection|
      connection.send_data data
    end
    puts "#{sender}@#{room} > #{message}"
  end
end

EM::run do
  EM::start_server('0.0.0.0', 3001, ChatServer)
end
