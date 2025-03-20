require "socket"

class YourRedisServer
  def initialize(port)
    @port = port
  end

  def start
    # You can use print statements as follows for debugging, they'll be visible when running tests.
    puts("Logs from your program will appear here!")
    
    # initialize data store
    puts "initializing data store..."
    @db = DataStore.new
    puts "Done."

    puts "Listening for connections..."
    # Uncomment this block to pass the first stage
    server = TCPServer.new(@port)
    loop do
      Thread.start(server.accept) do |client|
        puts "Processing a request..."
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

        print "processing_command #{args.inspect}\n"
        response = process_cmd(args)

        client.puts "+#{response}\r\n"
        client.close
        puts "Request closed."
      end
    end
  end

  def process_cmd(raw_cmd)
    cmd = raw_cmd.shift
    args = raw_cmd

    case cmd.downcase
    when "ping"
      "PONG"
    when "echo"
      args.join(' ')
    when "set"
      @db.set(args[0], args[1])
      "OK"
    when "get"
      @db.get(args[0])
    else
      "ERR-command not found"
    end
  end
end

class DataStore
  attr_accessor :store

  def initialize
    @store = {}
  end

  def set(key, value)
    store[key] = value
  end

  def get(key)
    store[key] || "Key Does Not Exists!!"
  end
end

YourRedisServer.new(6379).start
