# coding: utf-8
class SteamPlugin < BasePlugin
  def initialize()
    @actions = ['steamgift', 'delsteamgift', 'addsteamgift']
  end
  def steamgift(msg)
    case msg.message
    when /:add /
      addsteamgift(msg)
    when /:del /
      delsteamgift(msg)
    else
      liststeamgifts(msg)
    end
  end

  def addsteamgift(msg)
    game = msg.message.gsub(":add ", "").strip
    SteamGift.create :user_id => msg.user.dbid, :game_name => game, :gifted => false
    "Ok, added #{game}"
  end

  def delsteamgift(msg)
    game = msg.message.gsub(":del ", "").strip
    sg = SteamGift.find_by_user_id_and_game_name_and_gifted msg.user.dbid, game, false
    sg.gifted = true
    sg.save
    "Ok, removed #{game}"
  end

  def liststeamgifts(msg)
    case msg.message
    when /:user/
      un = msg.message.gsub(/:user/, "").strip
      u = User.fetch un, false
      sgs = SteamGift.find_all_by_user_id_and_gifted u.id, false
      print_gifts(sgs)
    else
      if msg.message.length > 0
        sgs = SteamGift.find :all, :conditions => "game_name ilike '%#{msg.message}%'" 
        print_gifts(sgs, true)
      else
        sgs = [SteamGift.find(:first, :conditions => "user_id <> #{msg.user.dbid}", :order => "RANDOM()")]
        print_gifts(sgs, true)
      end
    end
  end

  def print_gifts(gifts, print_user=false)
    if print_user
      gifts.map{|g| "%s - %s" % [g.game_name, g.user.to_s]}.join(", ")
    else
      gifts.map{|g| "%s" % [g.game_name]}.join(", ")
    end
  end
end
