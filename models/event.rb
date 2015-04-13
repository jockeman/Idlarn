# coding: utf-8
require 'time'
class Event < ActiveRecord::Base
  belongs_to :user

  def self.remember user, key, event
    tid = nil
    if event=~/@\((.*)\)/u
      tid = $1
      event.gsub!(/@\(.*\)/,'')
    else
      tid = event if TimeParser.get_date(event) rescue nil
    end
    key = key.downcase
    slut = nil
    if tid
     start, slut =  tid.split('till')
     tid = start 
    end
    Event.find_all_by_key(key).each{|e| e.in_use = false; e.save}
    Event.create({'key' => key, 'user_id' => (user.id rescue nil), 'starts_at' => tid, 'ends_at' => slut, 'event' => event})
    'Ok'
  end

  def self.random
    e = self.find_by_sql("SELECT * FROM events WHERE in_use = TRUE ORDER BY random() LIMIT 1")
    e.first.to_string
  end

  def self.naer key
    event = Event.find_by_key_and_in_use key, true
    key.gsub!(/_/,' ')
    return nil unless event
    event.to_string rescue nil
  end

  def startar
    @startar||=TimeParser.get_date(self.starts_at).to_time if self.starts_at rescue nil
  end

  def slutar
    @slutar||=TimeParser.get_date(self.ends_at).to_time rescue startar
  end

  def to_string
    str = "#{key.capitalize} #{event}" 
    if self.startar.nil?
      return str
    end
    nu = Time.now
    if self.startar < nu && self.slutar > nu
      str+= ", har börjat och fortsätter i %s till" 
      kvar_s = self.slutar - nu
    elsif self.startar < nu && self.slutar < nu
      if self.startar.to_date == nu.to_date && self.startar.hour == 0 && self.startar.min == 0
        return "#{key.capitalize} idag \\o/"
      elsif self.startar != self.slutar
        return "#{key.capitalize} var förr"
      else
        return str
      end
    else
      str+= ", %s kvar" 
      kvar_s = self.startar - nu
    end
    str % kvar_s.to_i.sec_to_string
  end

  def self.forget key
    e = Event.find_by_key_and_in_use(key, true)
    return nil if e.nil?
    e.in_use = false
    e.save
    'Ok'
  end

  def self.undo key
    e = Event.find_by_key_and_in_use(key, true)
    if e.nil?
      e = Event.find_by_key key
      e.in_use = true
      e.save
      return 'Ok'
    end
    oe = Event.find :first, :conditions => "key = '#{key}' AND created_at < '#{e.created_at}'", :order => 'created_at desc'
    return if oe.nil?
    e.in_use = false
    oe.in_use = true
    e.save
    oe.save
    'Ok'
  end

  def self.redo key
    e = Event.find_by_key_and_in_use(key, true)
    return if e.nil?
    ne = Event.find :first, :conditions => "in_use = false AND key = '#{key}' AND created_at > '#{e.created_at}'", :order => 'created_at asc'
    return if ne.nil?
    e.in_use = false
    ne.in_use = true
    e.save
    ne.save
    'Ok'
  end

  def self.list
#    es = self.find_all_by_in_use true, :conditions => "starts_at IS NOT NULL"
    es = self.where(in_use: true).where("starts_at IS NOT NULL")
    #es.each{|e| e['parsed_time'] = e.startar || (Time.now - 1000)}
    nu = Time.now
    es = es.select{|e| (e.startar || (Time.now - 1000)) > Time.now}
    es = es.sort_by{|e| (e.startar || (Time.now - 1000))}
  end
end
