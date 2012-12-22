# coding: utf-8
class Url < ActiveRecord::Base
  belongs_to :user
  require 'uri'
  require 'rack/utils'

  def self.compare ur, msg
    ur = self.normalize(ur)
    u = self.find_by_url_and_channel ur, msg.channel
    if u
      return nil if u.user_id == msg.user.dbid
      u.times = u.times.to_i + 1
      u.save
      return u
    end
    self.create :url => ur, :user_id => msg.user.dbid, :times => 0, :channel => msg.channel
    return nil
  end

  def self.normalize url
    host, path, qhash, anchor = self.parse url
    case host
    when /youtu\.be$/u
      host = 'www.youtube.com'
      qhash['v'] = path.gsub('/','')
      path = '/watch'
    when /youtube.com/u
      qhash.delete('hd')
    when /imgur\.com$/
      host='imgur.com'
      qhash={}
      path.gsub!(/\..*$/,'')
    end
    "%s%s%s%s" % [host, path, h2q(qhash), anchor]
  end

  def to_hip
    "%s gjorde den mainstream %s" % [self.user.to_s, self.created_at.to_s]
  end

  def to_s(extra=0)
    if times == 1
      "Först länkad av %s %s" % [self.user.to_s, self.created_at.to_s]
    else
      "Föst länkad av %s %s, länkad %d gånger" % [self.user.to_s, self.created_at.to_s, self.times+extra]
    end
  end
private
  def self.parse url
    uri = URI.parse(URI.decode(url))
    host = uri.host
    path = uri.path
    qhash = Hash[Rack::Utils.parse_nested_query(uri.query).sort]
    anchor = url=~/#/ ? url.sub(/^.*#/,'#') : ""
    [host, path, qhash, anchor]
  end

  def self.h2q(qhash)
    str = qhash.map{|k,v| "#{k}=#{v}"}.join('&')
    str.empty? ? str : '?'+str
  end



end
