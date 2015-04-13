# coding: utf-8
require 'digest/md5'
require 'shellwords'
class UrlsPlugin < BasePlugin
URLEX = /https?:\/\/[^ ]*/u
  def initialize()
    @actions = ['old', 'oldz', 'oldest', 'oldscore', 'oldscorep', 'randomknug', 'dagensknug']
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
      addmix(msg) if msg.message.downcase.scan(/dagens ?mix/).length > 0
      addmix(msg) if msg.message.downcase.scan(/dagens umpa/).length > 0
      addknug(msg) if msg.message.downcase.scan(/knug/).length > 0
      hash = save_img(msg) if msg.message.downcase.scan(/jpg|jpeg|png|gif|bmp/).length > 0
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

    def save_img(msg)
      puts "Bild! from " + msg.channel
      return if msg.channel == "dv_foto"
      urs = msg.message.scan URLEX
      begin
      `cd /home/idlarn/slaskbilder/; /usr/bin/wget -b #{urs.first.shellescape}`
      `cd /home/idlarn; /bin/echo #{urs.first.shellescape} > picbuff.tmp && /usr/bin/curl #{urs.first.shellescape} | /usr/bin/jp2a --colors --width=55 - >> picbuff.tmp && /bin/cat picbuff.tmp >> picbuff.txt`
      rescue StandardError => e
        puts e.message
      end
      return nil
    end

    def addmix(msg)
      puts "Mixx!"
      urs = msg.message.scan URLEX
      return nil if urs.length < 1
      url = urs.first
      datum = (Time.now.to_date + 1).to_time
      dagstart = (datum.to_date - 1).to_time

      if Mix.where("created_at BETWEEN '%s' AND '%s'" % [dagstart, datum]).find_by_user_id msg.user.dbuser.id
        puts "Har redan postat idag"
        return nil
      end
      Mix.create :user_id => msg.user.dbuser.id, :url => url, :created_at => Time.now
    end

    def addknug(msg)
      puts "Knug!"
      urs = msg.message.scan URLEX
      return nil if urs.length < 1
      url = urs.first

      Knug.create :user_id => msg.user.dbuser.id, :url => url, :created_at => Time.now
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
      #users = User.find :all, :order => 'oldz desc', :limit => 10, :conditions => 'oldz > 0'
      users = User.where("oldz > 0").order("oldz desc").limit(10).includes(:urls) 
      usrs = []
      users.each_with_index do |u, i|
        pcount = u.urls.count + u.oldz.to_i
        oldprcnt = u.oldz.to_f / pcount if pcount
        oldprcnt||=0
        oldprcnt = oldprcnt*100
        usrs << ("[%d] %s: %d/%d (%.1f%%)" % [i+1, u.to_s, u.oldz, (pcount||0), oldprcnt])
      end
      usrs.join(', ') unless usrs.empty?
    end

    def oldscorep(msg)
      stats = Url.joins(:user).group(:user_id, :oldz).count
      entries = stats.select{|k,v| v>50}.map{|k,v| [k.last.to_f/v ,k.first, k.last, v]}.sort[0..9]
      usrs = []
      entries.each_with_index do |e, i|
        u = User.find e[1]
        usrs << ("[%d] %s: %d/%d (%.1f%%)" % [i+1, u.to_s, e[2], e[3], e[0]*100])
      end
      usrs.join(', ') 
    end

    def randomknug(msg)
      k = Knug.first :order => "RANDOM()"
      k.url
    end
    alias :dagensknug :randomknug
#  end
end
