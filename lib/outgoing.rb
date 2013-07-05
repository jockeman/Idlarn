class Outgoing
  def initialize(channel, message, opts={})
    @channel = channel
    @message = message
    @priv = opts[:priv]
    @mode = opts[:mode]
    `echo "[#{Time.now.strftime "%F %T"} | ME] #{@message}" >> /home/idlarn/log/#{@channel}.log` if @message
    end

  def to_s()
    if @priv
      "PRIVMSG %s :%s" % [@channel, @message]
    elsif @mode
      "MODE #%s %s" % [@channel, @message]
    else
      "PRIVMSG #%s :%s" % [@channel, @message]
    end
  end
end
