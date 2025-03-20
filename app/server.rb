require "socket"

class YourRedisServer
  def initialize(port)
    @port = port
  end

  def start
    # You can use print statements as follows for debugging, they'll be visible when running tests.
    puts("Logs from your program will appear here!")

    # Uncomment this block to pass the first stage
    server = TCPServer.new(@port)
    loop do
      Thread.start(server.accept) do |client|
        raw_request = []
        raw_request << client.gets
        num_args = raw_request.first.strip[1..-1].to_i
        args = []
        num_args.times do
          size = client.gets.strip[1..-1].to_i  # Read the size of each argument
          arg = client.read(size)  # Read the argument itself
          args << arg
          client.gets  # Consume the \r\n after the argument
        end
        command = args.shift
        print args
        if command.downcase == "ping"
          response = "PONG"
        elsif command.downcase == "echo"
          response = args.join(' ')
        else
          response = "ERR-command not found"
        end
      client.puts "+#{response}\r\n"
        client.close
      end
    end
  end
end

YourRedisServer.new(6379).start
