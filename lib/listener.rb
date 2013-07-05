class Listener
  attr_accessor :irc
  def initialize(q, irc)
    @que = q
    @irc = irc
  end

  def stop!
    @running = false
    @thr.value
  end

  def kill!
    @thr.kill
    @thr.value
  end

  def run!
    @running = true
    @thr = Thread.new do
      while @running
        msg = @irc.read() rescue nil
        next if msg.nil?
        parse_input(msg) rescue nil
      end
    end
  end

  def parse_input(msg)
    case msg.strip
    when Regexps::PING
      pong($3)
    when Regexps::JOIN
      join($1,$2,$3,$4)
    when Regexps::PART,Regexps::QUIT
      part($1,$2,$3,$4)
    when Regexps::NICK
      nick($1,$2,$3,$4)
    when Regexps::MESSAGE
      msg($1,$2,$3,$4,$5)
    when Regexps::CTCP_PING
      puts "CTCP_PING %s" % msg.strip
    when Regexps::CTCP_VERSION
      puts "CTCP_VERSION %s" % msg.strip
    when /^:[^ ]+ 376/
      @irc.join('dv')
      @irc.join('dv_foto')
      @irc.join('update')
    else
      #other($1, $2, $3, $4, $5)
      #say(msg)
      puts msg.strip
    end
  end

  def pong(host)
    @irc.send_message("PONG %s" % host)
  end

  def join(nick, uname, host, chan)
    @que << RawMessage.new(:join, nick, uname, host, chan)
  end

  def part(nick, uname, host, qmsg)
    @que << RawMessage.new(:part, nick, uname, host, nil, qmsg)
  end

  def nick(nick, uname, host, new_nick)
    @que << RawMessage.new(:nick, nick, uname, host, nil, new_nick)
  end

  def msg(nick, uname, host, chan, msg)
    @que << RawMessage.new(:msg, nick, uname, host, chan, msg)
  end

end
