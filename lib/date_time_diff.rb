# coding: utf-8
class DateTimeDiff
  attr_accessor :start_date, :end_date
  attr_reader :years, :months, :days
  def initialize(a, b)
    self.start_date = a
    self.end_date = b
  end

  def diff
    @years = end_date.year - start_date.year
    @months = end_date.month - start_date.month
    @days = end_date.mday - start_date.mday
    if @days < 0
      @days+= (start_date.beginning_of_month.next_month - 1).mday
      @months-=1
    end
    if @months < 0
      @months+=12
      @years-=1
    end
    [@years, @months, @days]
  end

  def to_string
    s = []
    if @years > 0
      s << "#{@years} år"
    end
    if @months > 1
      s << "#{@months} månader"
    elsif @months == 1
      s << "1 månad"
    end
    if @days > 1
      s << "#{@days} dagar"
    elsif @days == 1
      s << "en dag"
    end
    str = ""
    if s.length > 1
      str = " och " + s[-1]
    end
    str = s[0...-1].join(", ") + str
  end
end

