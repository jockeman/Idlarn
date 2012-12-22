# coding: utf-8
module TimeParser
  require 'date'
  require 'time'

  def self.get_date(str)
    dates = get_dates(str)
    today = Date.today#current
    tid = Time.parse(str) rescue nil
    datum = dates.select{|d| d >= today}.first || dates.last
    if datum && tid
    datum.to_time + (tid - tid.to_date.to_time) if datum && tid
    else
      datum.to_time || tid
    end
  end

  private

  def self.tokenize(str)
    str.downcase.split('.').first.split rescue nil
  end

  def self.get_month(arr)
    head = arr.delete_at(0) if arr && arr.first == 'i'
    repeat, numerator, rest = to_num(arr) if arr.first=~/^var/
    rumerator, arr = get_mnum(arr) if numerator.nil?
    return [true, 1] if repeat.nil? and numerator.nil?
    [repeat, numerator]
  end

  def self.get_day(arr)
    return nil if arr.nil?
    begin 
      repeat, numerator, arr = to_num(arr)
    end while(numerator == 0 && !arr.empty?)
    wday, arr = get_wday(arr)
    return nil if wday.nil?
    [repeat, numerator, wday, get_month(arr)]
  end

  def self.to_num(arr)
    head = arr.delete_at(0)
    numerator = nil
    repeat = false
    if head == 'var'
      repeat = true
      head = arr.delete_at(0)
    elsif head == 'varje' || head.nil?
      numerator = 1
      repeat = true
      return [repeat, numerator, arr]
    end
    numerator = case head
      when 'första'
        1
      when 'andra', 'annan'
        2
      when 'tredje'
        3
      when 'fjärde'
        4
      when 'femte'
        5
      else
        head.to_i
      end
    [repeat, numerator, arr]
  end

  def self.get_wday(arr)
    str = arr.delete_at(0)
    wd = case str
    when /^(mån(dag(en)?)?$)|(mon(day)?$)/
      1
    when /^(tis(dag(en)?)?$)|(tue(sday)?$)/
      2
    when /^(ons(dag(en)?)?$)|(wed(nesday)?$)/
      3
    when /^(tors(dag(en)?)?$)|(thu(rsday)?$)/
      4
    when /^(fre(dag(en)?)?$)|(fri(sday)?$)/
      5
    when /^(lör(dag(en)?)?$)|(sat(ursday)?$)/
      6
    when /^(sön(dag(en)?)?$)|(sun(day)?$)/
      7
    when /dag(en)?/
      0
    end
    [wd, arr]
  end

  def self.get_mnum(arr)
    str = arr.delete_at(0)
    mn = (Time.parse(str).month rescue 0)
    [mn, arr]
  end

  def self.get_dates(str)
    arr = get_day(tokenize(str))
    return [] if arr.nil?
    year = Date.today.year#current.year
    months = parse_m arr.pop
    day = arr
    (year..year+1).map do |y|
      months.map do |m|
        days = parse_d day, m, y
      end
    end.flatten
  end

  def self.parse_m m
    if m.first
      (0..12).step(m.last).to_a[1..-1]
    else
      [m.last]
    end
  end

  def self.parse_d d, m, y
    date = Date.new(y,m,1)
    wday = date.wday
    days = []
    day = step = 1
    if d[2]!=0
      day+= (d.last-wday)%7
      step = 7
    end
    days << Date.new(y,m,day)
    while(tmp = days.last+step;tmp.month == m) do ; days << tmp; end
    if d.first
      days.each_with_index.select{|o, i| (i+1) % d[1] == 0}.map{|o, i| o}
    else
      days[d[1]-1...d[1]]
    end
  end
end
