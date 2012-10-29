require 'pty'
require 'eventmachine'

system("stty raw -echo")

$pty_reader, $pty_writer, $pty_pid = PTY.spawn("/bin/bash")

$logger = open("script.log", "wb")

class TerminalReader < EventMachine::Connection
  def receive_data(data)
    $pty_writer.print data
  end

  def unbind
    EM.stop
  end
end

class PTYReader < EventMachine::Connection
  def receive_data(data)
    $stdout.print data
    $logger.print data
  end

  def unbind
    EM.stop
  end
end

EM.run do
  EM.attach $stdin, TerminalReader
  EM.attach $pty_reader, PTYReader
end

at_exit do
  system("stty -raw echo")
end
