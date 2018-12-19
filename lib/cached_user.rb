class CachedUser
  attr_reader :nick, :uname, :host, :dbid, :dbuser
  attr_accessor :ignore, :previous, :last_karma, :velocity
  def initialize(msg)
    u = User.fetch msg.nick, true
    @dbuser = u
    @dbid = u.id
    @nick = msg.nick
    @uname = msg.uname
    @host = msg.host
    @ignore = u.ignored
    @previous = {}
    @last_karma = nil
    @velocity = []
  end

  def rename(new_nick)
    u = User.find @dbid
    @nick = new_nick
    u.rename new_nick
    @dbuser = u
  end

  def set_ignore(bool=true)
    u = User.find @dbid
    @ignore = bool
    u.ignored = bool
    u.save
  end

  def authenticated()
    @authenticated || false
  end

  def authenticate(password)
    return false unless User.find(@dbid).authenticate(password)
    @authenticated = true
  end
end
