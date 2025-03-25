require_relative 'data_store'
require_relative 'modules/process_commands'


class RedisAOF
  include ProcessCommands

  AOF_FILE = './backup.aof'
  SLEEP_INTERVAL = 2 # seconds
  def initialize
    @aof_buffer = []
    @lock = Mutex.new
    start_background_job_to_flush
    @db = DataStore.new
  end

  def log_command(cmd)
    @lock.synchronize { @aof_buffer << cmd }
  end 

  def replay_commands
    puts "restoring data..."
    backup_file = File.open(AOF_FILE, 'r')
    backup_file.each_line do |line|
      process_cmd(line.strip.split(' '))
      print('.')
    end
    backup_file.close
    puts "Done."
  end

  def backup_commands(raw_cmd)
    return unless BACKUP_COMMANDS.include? raw_cmd[0]
    
    raw_cmd = get_expireat_command(raw_cmd) if raw_cmd[0] == 'expire'
    log_command(raw_cmd.join(' ') + "\n")
  end

  private

  def get_expireat_command(raw_cmd)
    raw_cmd[2] = (Time.now.to_i + raw_cmd[2].to_i).to_s
    raw_cmd[0] = 'expireat'
    raw_cmd
  end

  def start_background_job_to_flush
    Thread.new do
      loop do 
        sleep SLEEP_INTERVAL
        flush_to_disk
      end
    end
  end

  def flush_to_disk
    @lock.synchronize do
      file = File.open('./backup.aof', 'a')
      @aof_buffer.each { |cmd| file.puts(cmd) }
      file.fsync
      file.close
    end
    @aof_buffer.clear
  end
end