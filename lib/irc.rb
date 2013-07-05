class IRC
  require 'socket'
  attr_reader :users
  attr_reader :host, :port, :nick
  def initialize host, port, nick='HipsterN^'
    @host = host
    @port = port
    @nick = nick
    @name = 'Irc Connector Framework'
    @uname = 'icf'
    connect()
  end

  def read()
    ready = select([@irc], nil, nil, 600)
    for s in ready[0]
      if s == @irc
        if @irc.eof?
          connect()
          next
        end
        return s.gets
      else
        puts s.inspect
      end
    end
    return nil
  end

  def change_nick(new_nick)
    @nick = new_nick
    send_message "NICK #{@nick}"
  end

  def send_message(msg)
    return if msg.nil?
    @irc.puts("%s\r\n" % msg.to_s)
    puts "--> %s" % msg
  end

  def disconnect(str = 'Changing batteries')
    #send_message "QUIT :#{str}" 
    #@irc.close
  rescue
    nil
  end

  def join(chan)
    send_message('JOIN :#%s' % chan.to_s)
  end

  def reconnect()
    disconnect()
    connect()
  end

private
  def connect()
    print "Connecting"
    @irc = TCPSocket.open(@host, @port)
    print "Connected"
    send_message "USER #{@uname} 0 * :#{@name}"
    send_message "NICK #{@nick}"
  rescue
    nil
  end
end
