#load 'db.rb'
#include Db

def merge(userid, alts)
  user = User.find userid
  alts.each do |altid|
    altu = User.find altid
    user.oldz+=altu.oldz
    alt = Alt.find_or_create_by_user_id_and_nick user.id, altu.nick
    quotes = Quote.find_all_by_user_id altu.id
    quotes.each do |q|
      q.user_id = user.id
      q.save
    end
    quotes = Quote.find_all_by_adder altu.id
    quotes.each do |q|
      q.adder = user.id
      q.save
    end
    urls = Url.find_all_by_user_id altu.id
    urls.each do |u|
      u.user_id = user.id
      u.save
    end
    alts = Alt.find_all_by_user_id altu.id
    alts.each do |alt|
      alt.user_id = user.id
      alt.save
    end
#    altu.channel_users.each{|c| c.delete}
    altu.delete
  end
  user.save
end
