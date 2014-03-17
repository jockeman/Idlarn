#load 'db.rb'
#include Db

def merge(userid, alts)
  user = User.find userid
  alts.each do |altid|
    altu = User.find altid
    user.oldz+=altu.oldz
    user.karma+=altu.karma
    user.birthdate = user.birthdate || altu.birthdate
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
    mixs = Mix.find_all_by_user_id altu.id
    mixs.each do |mix|
      mix.user_id = user.id
      mix.save
    end
    mixrs = MixRank.find_all_by_user_id altu.id
    mixrs.each do |mixr|
      mixr.user_id = user.id
      mixr.save
    end
    semesters = Semester.find_all_by_user_id altu.id
    semesters.each do |semester|
      semester.user_id = user.id
      semester.save
    end
#    altu.channel_users.each{|c| c.delete}
    altu.delete
  end
  user.save
end
