require 'eventmachine'

system("stty raw -echo")

at_exit do
  system("stty -raw echo")
end

class ServerConnection < EventMachine::Connection
  def receive_data(data)
    $stdout.print data
  end

  def unbind
    EM.stop
  end
end

class TerminalReader < EventMachine::Connection
  def receive_data(data)
    $server.send_data data
  end

  def unbind
    EM.stop
  end
end

EM.run do
  $server = EM.connect '127.0.0.1', 5000, ServerConnection
  EM.attach $stdin, TerminalReader
end
