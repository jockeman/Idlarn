# coding: utf-8
class CommandPlugin < BasePlugin
  def initialize()
    @actions = ['auth', 'ignore', 'unignore', 'opme']
    @regexps = []
  end
#  class << self
    def action(msg)
      if msg.action != 'auth'
        return nil unless msg.user.authenticated
        return opme(msg) if msg.action == 'opme'
        super
      else
        resp = auth(msg)
        build_response(resp, msg, {:priv => true})
      end
    end

    def auth(msg)
      return nil if msg.channel=~ /^#([^\s]+)/
      msg.user.authenticate(msg.message).to_s
    end

    def opme(msg)
      user = msg.user.nick
      channel = msg.message
      Outgoing.new(channel, "+o #{user}", {:mode => true})
    end

    def ignore(msg)
      user = Users.find_by_nick msg.message
      return "Couldn't find #{msg}" if user.nil?
      user.set_ignore(true)
      "Ignored #{msg}"
    end

    def unignore(msg)
      user = Users.find_by_nick msg.message
      return "Couldn't find #{msg}" if user.nil?
      user.set_ignore(false)
      "Unignored #{msg}"
    end
#  end

end
