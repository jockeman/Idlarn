# coding: utf-8
module TimeParser
  require 'date'
  require 'time'
  #require 'hday'

  class PacMan
    NUMBER = /^första$|^andra$|^tredje$|^fjärde$|^femte$|^\d|^sista$/
    REPEAT = /^var(je)?$/
    MONTH = %w(januari februari mars april maj juni juli augusti september oktober november december)
    VARDAG = /^vardag(en)?$/
    WDAY = /^(mån|tis|ons|tors|fre|lör|sön)?(dag(en|ar)?)?$/
    CLOSE_MONTH = /^månad(en)?$/
    BEFORE = /^före$|^innan$/
    AFTER = /^efter$/
    YEAR = /^år$/
    KVARTAL = /^kvartal$/
    HALF_YEAR = /^halvår$/
    attr_reader :stack
    def initialize()
      @stack = {}
      @current = @stack
    end

    def parse_wday(str)
      case str
      when /^(mån(dag(en|ar)?)?$)|(mon(day)?$)/
        [1]
      when /^(tis(dag(en|ar)?)?$)|(tue(sday)?$)/
        [2]
      when /^(ons(dag(en|ar)?)?$)|(wed(nesday)?$)/
        [3]
      when /^(tors(dag(en|ar)?)?$)|(thu(rsday)?$)/
        [4]
      when /^(fre(dag(en|ar)?)?$)|(fri(sday)?$)/
        [5]
      when /^(lör(dag(en|ar)?)?$)|(sat(ursday)?$)/
        [6]
      when /^(sön(dag(en|ar)?)?$)|(sun(day)?$)/
        [7]
      when /^vardag(en|ar)?$/
        [1,2,3,4,5]
      when /dag(en|ar)?/
        [1,2,3,4,5,6,7]
      end
    end

    def make_date_base(stack, base)
      year = stack.delete(:year)
      month = stack.delete(:month)
      day = stack.delete(:day)
      extra = stack.delete(:num)
      unless extra.nil?
        day = {:num => extra} if day.nil?
      end
      if year
        if year[:repeat]
          ys = (base.year..base.year+10).step(year[:repeat]).to_a
        else
          ys = [year[:num]]
        end
      else
        ys = [base.year, base.year+1]
      end

      if month
        if month[:repeat]
        ms = (1..12).step(month[:repeat]).to_a
          ms = ms.map{|m| m+=month[:num]-1} if month[:num] and month[:num] > 0
          ms = ms.map{|m| m+=month[:repeat]+month[:num]-1} if month[:num] and month[:num] <= 0
        else
          ms = [month[:num]]
        end
      end

      if day
        step = day[:repeat] || 1
        wdays = day[:wday] || (1..7)
        num = day[:num]
        vardag = day[:vardag] || false
      else
        step = 1
        wdays = (1..7)
        num = 1
        vardag = false
      end
      [ys, ms, step, wdays, num, vardag]
    end

    def make_special(stack)
      special = stack.delete(:special)
      if special
        special = special.sub(/:/,'').to_sym
        if stack[:year]
          year = stack[:year][:num]
        end
        year||= Date.today.year
        hdays = Hday.special_days_for_year(year)
        return hdays[special] if hdays.has_key? special
      end
    end

    def make_date_before(stack, base)
      special = make_special(stack)
      return special if special
      ys, ms, step, wdays, num, vardag = make_date_base(stack, base)
      dates = if ms
        ys.map do |y|
          ms.map do |m|
            days = Date.new(y, m).step(Date.new(y,m,-1),step)
            days = days.select{|d| wdays.include?(d.cwday)}
          end
        end.flatten
      else
        days = Date.new(base.year-1,-1,-1).step(base,step)
        days = days.select{|d| wdays.include?(d.cwday)}.reverse
      end
      dates = dates.select{|d| !Hday.is_holiday(d)} if vardag
      dates = [dates[num-1]] if num
      datum = dates.select{|d| d <= base}.last || dates.first
    end

    def make_date_after(stack, base=DateTime.now)
      special = make_special(stack)
      return special if special
      ys, ms, step, wdays, num, vardag = make_date_base(stack, base)
      dates = if ms
        ys.map do |y|
          ms.map do |m|
            days = Date.new(y, m).step(Date.new(y,m,-1),step)
            days = days.select{|d| wdays.include?(d.cwday)}
          end
        end.flatten
      else
        days = base.step(Date.new(base.year+1,-1,-1),step)
        days = days.select{|d| wdays.include?(d.cwday)}
      end
      dates = dates.select{|d| !Hday.is_holiday(d)} if vardag
      dates = [dates[num-1]] if num
      datum = dates.select{|d| d >= base}.first || dates.last
    end

    def fnirk(stack, base=nil)
      if stack[:before]
        make_date_before(stack, fnirk(stack[:before]))
      elsif stack[:after]
        make_date_after(stack, fnirk(stack[:after]))
      else
        make_date_after(stack)
      end
    end

    def fnork
      puts @stack
      fnirk(@stack)
    end

    def push(h)
      h.each do |k, v|
        case k
        when :repeat
          @current.update(:repeat => v)
        when :num
          if @current[:repeat]
            @current[:repeat] = v 
          elsif @current[:year] && @current[:year][:num].nil?
            @current[:year].update h
          else
            @current.update(h)
          end
        when :type
          @current[v]||={}
          @current[v].update(:num => (@current.delete :num) ) if @current[:num]
          @current[v].update(:repeat => (@current.delete :repeat)) if @current[:repeat]
        when :wday
          @current[:day]||={:wday => []}
          @current[:day][:wday]+= v
          @current[:day].update(:num => (@current.delete :num) ) if @current[:num]
          @current[:day].update(:repeat => (@current.delete :repeat)) if @current[:repeat]
        when :before
          before = {}
          @current[:before] = before
          @current = before
        when :after
          after = {}
          @current[:after] = after
          @current = after
        when :vardag
          @current[:day]||={}
          @current[:day][:vardag] = true
        else
          @current.update(h)
        end
      end
    end

    def eat_token(token)
      case token
      when NUMBER
        push :num => parse_int(token)
      when REPEAT
        push :repeat => 1
      when /^#{MONTH.join('$|^')}$/
        push :month => {:num=>MONTH.index( token)+1}
      when VARDAG
        push :wday => parse_wday(token), :vardag => true
      when WDAY
        push :wday => parse_wday(token)
      when CLOSE_MONTH
        push :type => :month
      when YEAR
        push :type => :year
      when KVARTAL
        push :repeat => 3, :type => :month
      when HALF_YEAR
        push :repeat => 6, :type => :month
      when BEFORE
        push :before => true
      when AFTER
        push :after => true
      when /^:[a-z]*$/
        push :special => token
      else
        nil
      end
    end

    def parse_int(token)
      numerator = case token 
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
      when 'sista'
        0
      else
        token.to_i
      end
    end
  end

  def self.parse(str)
    tokens = str.downcase.split('.').first.split rescue (return nil)
    eater = PacMan.new
    tokens.each {|token| eater.eat_token(token)}
    datum = (eater.fnork rescue nil)
    tid = (Time.parse(str) rescue nil)
    if datum && tid
      datum.to_time + (tid - tid.to_date.to_time)
    else
      datum.to_time || tid.to_date.to_time
    end
  end
end
