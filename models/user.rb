class User < ActiveRecord::Base
  has_many :channel_users
  has_many :alts
  has_many :quotes
  has_many :urls
  has_many :semesters
  has_many :jobs
  has_many :mix
  has_many :mix_ranks
  attr_reader :icon

  def self.fetch nick, store=true
    nick = nick.downcase.strip
    user = self.find_by_display(nick) or self.find_by_nick(nick)
    user = (alt = Alt.find_by_nick(nick)) && alt.user if user.nil?
    user = self.create :nick => nick, :display => nick if user.nil? && store
    user.nick = nick unless user.nick == nick if user
    user.save if user
    user
  end

  def rename new_nick
    Alt.find_or_create_by(user_id: self.id, nick: nick)
    self.nick = new_nick
    self.save
  end

  def self.log_action nick, channel_name, action, msg=nil
    channel_name = channel_name.gsub(/#/,'').upcase
    user = self.fetch nick
    puts "[%s@%s] %s %s" % [action, channel_name, (nick + ":").ljust(10), msg]
  end

  def self.get_karma nick
    user = self.fetch nick, false
    "#{nick}@#{user.karma.to_s}" if user
  end

  def self.up_karma nick
    user = self.fetch nick, false
    return nil if user.nil?
    user.karma+=1
    user.save
    'Ok'
  end

  def self.down_karma nick
    user = self.fetch nick, false
    return nil if user.nil?
    user.karma-=1
    user.save
    'Ok'
  end

  def to_s
    "%s_%s" % [self.display[0..0], self.display[1..-1]]
  end
end
