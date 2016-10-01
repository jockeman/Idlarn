# coding: utf-8
class RawMessage
  attr_reader :type, :nick, :uname, :host, :channel, :payload
  def initialize(type, nick, uname, host, channel=nil, payload=nil)
    @type = type
    @nick = nick
    @uname = uname
    @host = host
    @channel = channel
    @payload = payload.force_encoding('utf-8') if payload
    if @payload && !@payload.valid_encoding?
      @payload.encode!("UTF-8", "ISO-8859-15")
    end
    puts "[%s#%s] %s" % [@nick, @channel, @payload] if @payload
    `echo "[#{Time.now.strftime "%F %T"} | #{@nick}] #{@payload}" >> ~/log/#{@channel == 'HipsterN^' ? @nick : @channel}.log` if @payload
  end
end
