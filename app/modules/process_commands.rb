module ProcessCommands
  BACKUP_COMMANDS = %w[set expire expireat].freeze

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
    when "expire"
      @db.set_expiry(args[0], seconds: args[1])
    when "expireat"
      @db.set_expiry(args[0], expire_at: args[1])
    when "ttl"
      @db.ttl(args[0])
    else
      "ERR-command not found"
    end
  end
end
