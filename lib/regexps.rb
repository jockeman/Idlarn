module Regexps
  PING = /^PING :(.+)$/i
  HOSTMASK = ":(.+?)!(.+?)@(.+?)\s"
  CHAN = "#?([^\s]+)\s"
  PRIVMSG = "#{HOSTMASK}PRIVMSG\s#{CHAN}"
  NN1 = "[\x01]"
  CTCP_PING = /^#{PRIVMSG}:#{NN1}PING (.+)#{NN1}$/i
  CTCP_VERSION = /^#{PRIVMSG}:#{NN1}VERSION (.+)#{NN1}$/i
  MESSAGE = /^#{PRIVMSG}:(.+)$/i
  JOIN = /^#{HOSTMASK}JOIN\s:#(.+)$/
  PART = /^#{HOSTMASK}PART\s:(.+)$/
  QUIT = /^#{HOSTMASK}QUIT\s:(.+)$/
  NICK = /^#{HOSTMASK}NICK\s:(.+)$/

  CTCP_PING_REPLY = "NOTICE %s :\001PING %s\001"
  CTCP_VERSION_REPLY = "NOTICE %s :\001VERSION %s\001"
end
