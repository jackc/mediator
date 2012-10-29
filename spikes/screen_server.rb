require 'pty'
require 'eventmachine'

$pty_reader, $pty_writer, $pty_pid = PTY.spawn("/bin/bash")

class ClientConnection < EventMachine::Connection
  @@client_connections = []
  
  def post_init
    @@client_connections.push(self)
    puts "A client connected..."
  end

  def receive_data(data)
    $pty_writer.print data
  end

  def unbind
    @@client_connections.delete(self)
    puts "A client disconnected..."
  end

  def self.broadcast(data)
    @@client_connections.each do |c|
      c.send_data(data)
    end
  end
end

class PTYReader < EventMachine::Connection
  def receive_data(data)
    ClientConnection.broadcast data
  end

  def unbind
    EM.stop
  end
end

EM.run do
  EM.start_server '127.0.0.1', 5000, ClientConnection
  EM.attach $pty_reader, PTYReader
end
