# coding: utf-8
require 'digest/md5'
class UrlsPlugin < BasePlugin
URLEX = /https?:\/\/[^ ]*/u
  def initialize()
    @actions = ['old', 'oldz', 'oldest', 'oldscore']
    @regexps = [URLEX]
  end

  #class << self

    def action(msg)
      if msg.action
        super
      else
        resp = url(msg)
        build_response(resp, msg) if resp
      end
    end

    def url(msg)
      urs = msg.message.scan URLEX
      urs.map do |ur|
        if (u = Url.compare(ur, msg))
          usr = msg.user.dbuser
          usr.oldz = usr.oldz.to_i+1
          usr.save
          "Jösses Amalia vad ute du är, " + u.to_hip
        end
      end.compact
    end

    def old(msg)
      message = Url.normalize msg.message
      oldz = Url.find :first, :conditions => "url ILIKE '%#{message}%'" , :order => 'RANDOM()'
      url = oldz.url
      url = 'http://'+ url unless url=~/^http/
      url + ' ' + oldz.to_s(1) if oldz
    end

    def oldz(msg)
      u = if msg.message.empty?
        User.fetch msg.user.nick, false
      else
        User.fetch msg.message, false
      end
      pcount = u.urls.length + u.oldz.to_i
      oldprcnt = u.oldz.to_f / pcount if pcount
      oldprcnt||=0
      oldprcnt = oldprcnt*100
      "%s har postat %d oldz (%.1f%%), totalt %d länkar" % [u.to_s, u.oldz, oldprcnt, (pcount||0)]
    end

    def oldest(msg)
      u = User.find :first, :order => 'oldz desc'
      pcount = u.urls.length + u.oldz.to_i
      oldprcnt = u.oldz.to_f / pcount if pcount
      oldprcnt||=0
      oldprcnt = oldprcnt*100
      "%s har postat %d oldz (%.1f%%), totalt %d länkar" % [u.to_s, u.oldz, oldprcnt, (pcount||0)]
    end

    def oldscore(msg)
      users = User.find :all, :order => 'oldz desc', :limit => 10, :conditions => 'oldz > 0'
      usrs = []
      users.each_with_index do |u, i|
        pcount = u.urls.length + u.oldz.to_i
        oldprcnt = u.oldz.to_f / pcount if pcount
        oldprcnt||=0
        oldprcnt = oldprcnt*100
        usrs << ("[%d] %s: %d/%d (%.1f%%)" % [i+1, u.to_s, u.oldz, (pcount||0), oldprcnt])
      end
      usrs.join(', ') unless usrs.empty?
    end
#  end
end
