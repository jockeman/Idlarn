# coding: utf-8
class Quote < ActiveRecord::Base
  belongs_to :user
  belongs_to :channel

  def self.log_quote adder, channel_name, quote
    channel = Channel.find_or_create_by_name channel_name.upcase.gsub(/#/,'')
    puts "[%s@%s] %s" % ['QUOTE', channel.name, quote]
    self.create 'channel_id' => channel.id, 'quote' => quote, 'adder' => adder.id, 'timestamp' => Time.now
    "Ok, added #{quote}"
  end

  def self.get_quote str
    str = str.split
    q = if str.length == 2 && str.first =~ /^@([a-z]+)/
      case $1
      when 'adder'
        usr = User.fetch str[1].strip
        self.find :first, :conditions => "adder = '#{usr.id}'", :order => 'RANDOM()'
      when 'user'
        usr = User.fetch str[1].strip
        self.find :first, :conditions => "user_id = '#{usr.id}'", :order => 'RANDOM()'
      when 'notuser'
        usr = User.fetch str[1].strip
        self.find :first, :conditions => "user_id <> '#{usr.id}'", :order => 'RANDOM()'
      else
        nil
      end
    end
    if q.nil?
      str = str.join(' ')
      q = case str
      when ''
        self.find(:first, :order => 'RANDOM()')
      when /-[0-9]+/
        o = -(str.to_i) - 1
        self.find :first, order: 'id desc', offset: o
      when /[0-9]+/
        self.find str.to_i
      else
        str = str.downcase
        str.gsub!(/[^a-z0-9åäö]/,'')
        self.find :first, :conditions => "quote ILIKE '%#{str}%'", :order => 'RANDOM()'
      end
    end
    return nil if q.nil?
    user = User.find q.adder
    if q.timestamp
      "Quote #%d: %s (Added by: %s %s)" % [q.id, q.quote, user.to_s, q.timestamp.strftime("%Y-%m-%d")]
    else
      "Quote #%d: %s (Added by: %s)" % [q.id, q.quote, user.to_s]
    end
  end
end
