class Outgoing
  def initialize(channel, message, opts={})
    @channel = channel
    @message = message
    @priv = opts[:priv]
    @mode = opts[:mode]
    `echo "[#{Time.now.strftime "%F %T"} | ME] #{@message}" >> /home/idlarn/log/#{@channel}.log` if @message
    end

  def to_s(all_caps=false)
    @message.upcase! if all_caps
    if @priv
      "PRIVMSG %s :%s" % [@channel, @message]
    elsif @mode
      "MODE #%s %s" % [@channel, @message]
    else
      "PRIVMSG #%s :%s" % [@channel, @message]
    end
  end
end

class NormalMessage < Outgoing
  def initialize(channel, message)
    @channel = channel
    @message = message
    `echo "[#{Time.now.strftime "%F %T"} | ME] #{@message}" >> /home/idlarn/log/#{@channel}.log` if @message
    end

  def to_s(all_caps=false)
    @message.upcase! if all_caps
    "PRIVMSG #%s :%s" % [@channel, @message]
  end
end

class PrivateMessage < Outgoing
  def initialize(channel, message)
    @channel = channel
    @message = message
    `echo "[#{Time.now.strftime "%F %T"} | ME] #{@message}" >> /home/idlarn/log/#{@channel}.log` if @message
    end

  def to_s(all_caps=false)
    @message.upcase! if all_caps
    "PRIVMSG %s :%s" % [@channel, @message]
  end
end

class ModeMessage < Outgoing
  def initialize(channel, mode, user)
    @channel = channel
    @message = "%s %s" % [mode, user]
  end
  
  def to_s(all_caps=false)
    "MODE #%s %s" % [@channel, @message]
  end
end
