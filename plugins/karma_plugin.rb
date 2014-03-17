# coding: utf-8
class KarmaPlugin < BasePlugin
  KARMAUP = /^.*\+\+$/
  KARMADN = /.*--/
  def initialize()
    @actions = ['karma', 'karmatoppen', 'karmabotten']
    @regexps = [KARMAUP,KARMADN]
  end

  def action(msg)
    case msg.message
    when KARMAUP
      if msg.user.last_karma && (Time.now - msg.user.last_karma) < 60
        msg.user.last_karma = Time.now
        return build_response("#{msg.user.nick}: Lugna ner dig!", msg ) 
      end
      nick = msg.message.gsub(/\+\+$/,'')
      user = User.fetch nick, false
      return build_response("#{msg.user.nick}: Nice try, Bitch!", msg) if user.id == msg.user.dbid
      msg.user.last_karma = Time.now
      user.karma+=1
      user.save
    when KARMADN
      if msg.user.last_karma && (Time.now - msg.user.last_karma) < 60
        msg.user.last_karma = Time.now
        return build_response("#{msg.user.nick}: Lugna ner dig!", msg ) 
      end
      nick = msg.message.gsub(/--$/,'')
      user = User.fetch nick, false
      return build_response("#{msg.user.nick}: Nice try, Bitch!", msg) if user.id == msg.user.dbid
      msg.user.last_karma = Time.now
      user.karma-=1
      user.save
    else
      super
    end

  end

  def karma(msg)
    u = User.fetch msg.message, false
    u = msg.user.dbuser.reload if u.nil?
    "#{u.to_s} har %d karma" % u.karma if u
  end

  def karmatoppen(msg)
    list = User.all :order => "karma desc", :limit => 5
    karmas = []
    list.each_with_index do |u, i| 
      karmas << "[%d] %s: %d" % [i+1, u.to_s, u.karma]
    end
    karmas.join(", ")
  end


  def karmabotten(msg)
    list = User.all :order => "karma asc", :limit => 5
    karmas = []
    list.each_with_index do |u, i| 
      karmas << "[%d] %s: %d" % [i+1, u.to_s, u.karma]
    end
    karmas.join(", ")
  end
end
