# coding: utf-8
class MixPlugin < BasePlugin
URLEX = /https?:\/\/[^ ]*/u
  def initialize()
    @actions = ['dagensmix', 'dagensumpa', 'randommix', 'mixmasters', /dagens.*/, 'mixtoppen']
  end

    def action(msg)
      if msg.action
        if (msg.action.match(/dagens.*/) && msg.action != "dagensmix" && msg.action != "dagensumpa")
          resp = dagens(msg)
          build_response(resp, msg) if resp
        else
          super
        end
      else
        resp = addmix(msg)
        build_response(resp, msg) if resp
      end
    end

    def addmix(msg)
      urs = msg.message.scan URLEX
      return nil if urs.length < 1
      url = urs.first
      Mix.create :user_id => msg.user.id, :url => url, :created_at => Time.now
    end

  def randommix(msg)
    user = msg.message.scan /@user [^ ]*/
    if user.last
      user = user.last.split.last
      msg.message.gsub!(/@user [^ ]*/, "")
    else
      user = "Plux"
    end
    u = User.fetch user, false
    m = Mix.find_by_user_id u.id, :order => "RANDOM()"
    rank = MixRank.sum :rank, :conditions => {:mix_id => m.id}
    "%s@%s %s %d poäng" % [m.user.to_s, m.created_at.strftime("%Y-%m-%d"), m.url, rank]
  end

  def dagens(msg)
    nick = msg.action.gsub('dagens','')
    if nick == "mix"
      return dagensmix(msg)
    end
    u = User.fetch nick, false
    if u
      if msg.message.length > 0
        datum = (Time.parse msg.message) rescue Time.now
      else
        datum = Time.now
      end
      user = 
      datum = (datum.to_date + 1).to_time
      m = Mix.find :first, :conditions => "created_at <= '%s' AND user_id = %d" % [datum, u.id], :order => "created_at DESC"
      return "%s har inte postat några mixar" % u.to_s if m.nil?
      if msg.message.length > 0
        if msg.message.match(/\+\+/)
          mr = MixRank.find_or_create_by_user_id_and_mix_id msg.user.dbid, m.id
          mr.rank = 1
          mr.save
          return "Ok"
        elsif msg.message.match(/--/)
          mr = MixRank.find_or_create_by_user_id_and_mix_id msg.user.dbid, m.id
          mr.rank = -1
          mr.save
          return "Ok"
        end
      end
      rank = MixRank.sum :rank, :conditions => {:mix_id => m.id}
      "%s %s %d poäng" % [m.created_at.strftime("%Y-%m-%d"), m.url, rank]
    end
  end

  def dagensmix(msg)
    user = msg.message.scan /@user [^ ]*/
    spec = false
    if user.last
      user = user.last.split.last
      msg.message.gsub!(/@user [^ ]*/, "")
      spec = true
    else
      user = "Plux"
    end
    u = User.fetch user, false
    if msg.message.length > 0
      datum = (Time.parse msg.message) rescue Time.now
    else
      datum = Time.now
    end
    user = 
    datum = (datum.to_date + 1).to_time
    dagstart = (datum.to_date - 1).to_time

    m = Mix.find :first, :conditions => "created_at BETWEEN '%s' AND '%s' AND user_id = %d" % [dagstart, datum, u.id], :order => "created_at ASC"
    if m.nil? && spec == false
      m = Mix.find :first, :conditions => "created_at BETWEEN '%s' AND '%s'" % [dagstart,datum, u.id], :order => "created_at ASC"
    end
    if m.nil?
      spec = false
      m = Mix.find :first, :conditions => "created_at <= '%s' AND user_id = %d" % [datum, u.id], :order => "created_at DESC"
    end
      if msg.message.length > 0
        if msg.message.match(/\+\+/)
          puts msg.inspect
          mr = MixRank.find_or_create_by_user_id_and_mix_id msg.user.dbid, m.id
          mr.rank = [(mr.rank || 0) + 1, 1].min
          mr.save
          return "Ok"
        elsif msg.message.match("--")
          mr = MixRank.find_or_create_by_user_id_and_mix_id msg.user.dbid, m.id
          mr.rank = [(mr.rank || 0) - 1, 1].max
          mr.save
          return "Ok"
        end
      end
    rank = MixRank.sum :rank, :conditions => {:mix_id => m.id}
    if spec
      "%s %s %d poäng" % [m.created_at.strftime("%Y-%m-%d"), m.url, rank]
    else
      "%s@%s %s %d poäng" % [m.user.to_s, m.created_at.strftime("%Y-%m-%d"), m.url, rank]
    end
  end

  def dagensumpa(msg)
    user = msg.message.scan /@user [^ ]*/
    spec = false
    if user.last
      user = user.last.split.last
      msg.message.gsub!(/@user [^ ]*/, "")
      spec = true
    else
      user = "Pontus"
    end
    u = User.fetch user, false
    if msg.message.length > 0
      datum = Time.parse msg.message
    else
      datum = Time.now
    end
    user = 
    datum = (datum.to_date + 1).to_time
    dagstart = (datum.to_date - 1).to_time

    m = Mix.find :first, :conditions => "created_at BETWEEN '%s' AND '%s' AND user_id = %d" % [dagstart, datum, u.id], :order => "created_at ASC"
    if m.nil? && spec == false
      m = Mix.find :first, :conditions => "created_at BETWEEN '%s' AND '%s'" % [dagstart,datum], :order => "created_at ASC"
    end
    if m.nil?
      spec = false
      m = Mix.find :first, :conditions => "created_at <= '%s' AND user_id = %d" % [datum, u.id], :order => "created_at DESC"
    end
    if spec
      "%s %s" % [m.created_at.strftime("%Y-%m-%d"), m.url]
    else
      "%s@%s %s" % [m.user.to_s, m.created_at.strftime("%Y-%m-%d"), m.url]
    end
  end

  def mixtoppen(msg)
    toppen = MixRank.count :group => :mix_id, :order => "count_all DESC", :limit => 5
    p = 0
    toppen.map{|k,v| m = Mix.find(k); p+=1; "[%d] %s@%s %s: (%d poäng)" % [p, m.user.to_s, m.created_at.strftime("%Y-%m-%d"), m.url, v]}.join(', ')
  end

  def mixmasters(msg)
    masters = Mix.count :group => :user_id, :order => "count_all DESC", :limit => 5
    mms = masters.map{|k,v| "%s: %d" % [User.find(k).to_s, v]}.join(', ')
  end
end
