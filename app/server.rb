require "socket"
require_relative 'data_store'
require_relative 'redis_aof'
require_relative 'modules/process_commands'

class YourRedisServer
  include ProcessCommands

  def initialize(port)
    @port = port
    @db = DataStore.new
    @aof = RedisAOF.new
  end

  def start
    @aof.replay_commands

    # You can use print statements as follows for debugging, they'll be visible when running tests.
    puts("Logs from your program will appear here!")
    puts "Listening for connections..."

    # Uncomment this block to pass the first stage
    server = TCPServer.new(@port)
    loop do
      Thread.start(server.accept) do |client|
        raw_request = ''
        raw_request += client.gets
        num_args = raw_request.strip[1..-1].to_i
        args = []
        num_args.times do
          size = client.gets.strip[1..-1].to_i  # Read the size of each argument
          arg = client.read(size) 
          # Read the argument itself
          args << arg
          client.gets  # Consume the \r\n after the argument
        end

        @aof.backup_commands(args)
        print "processing_command #{args.inspect}\n"
        response = process_cmd(args)
        client.puts "+#{response}\r\n"
        client.close
        puts "Request closed."
        puts "Listening for connections..."
      end
    end
  end
end

YourRedisServer.new(6379).start
