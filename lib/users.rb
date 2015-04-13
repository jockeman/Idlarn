class Users
  def initialize()
    @users = {}
  end

  def get(msg, checkignore=true)
    key = build_key(msg.nick, msg.uname, msg.host)
    user = @users[key] ||= CachedUser.new(msg)
    raise "Ignored user" if checkignore && (user.ignore == true || (user.ignore.class == Time && user.ignore > Time.now))
    user
  end

  def rename(msg)
    puts [msg.payload, msg.nick, msg.uname, msg.host].inspect
    key = build_key(msg.nick, msg.uname, msg.host)
    user = get(msg, false)
    @users.delete(key)
    puts user.inspect
    user.rename(msg.payload)
    puts user.inspect
    new_key = build_key(msg.payload, msg.uname, msg.host)
    puts new_key
    @users[new_key] = user
  end

  def find_by_nick(nick)
    u = @users.select{|key, user| key.split(':').first == nick}.first
    u.values.first
  end
private
  def build_key(nick, uname, host)
    key = "%s:%s@%s" % [nick, uname, host]
  end
end

