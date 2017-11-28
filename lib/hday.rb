# coding: utf-8
module Hday
  require 'date'
 
  def self.is_holiday(date)
    date = date.to_date
    return false if date.year < 1000
    return true if [6,7].include? date.cwday
    holidays = free_days_for_year(date.year)
    holidays.values.include?(date)
  end

  def self.get_fettisdag(year)
    get_easter(year)-47
  end

  def self.get_easter(year)
    cent = year / 100
    n = year-19*(year/19)
    k = (cent-17)/25
    i = cent-cent/4-(cent-k)/3+19*n+15
    i = i-30*(i/30)
    i = i-(i/28)*(1-(i/28)*(29/(i+1))*((21-n)/11))
    j = year+year/4+i+2-cent+cent/4
    j = j-7*(j/7)
    l = i-j
    month = 3+(l+40)/44
    day = l+28-31*(month/4)
    Date.new(year,month,day)
  end
  
  def self.get_midsommar(year)
    date = Date.new(year,6,20)
    day = 6-date.cwday
    date+day
  end

  def self.get_allhelgona(year)
    date = Date.new(year,10,31)
    day = 6-date.wday
    date+day
  end
  def self.special_days_for_year(year)
    specials = holidays_for_year(year)
  end
  def self.free_days_for_year(year)
    free = holidays_for_year(year)
    free[:julafton] = Date.new(year,12,24)
    free[:nyarsafton] = Date.new(year,12,31)
    free[:midsommarafton] = get_midsommar(year).prev_day
    free[:pingst] = get_easter(year)+7*7
    return free
  end
  def self.holidays_for_year(year) 
    easter = get_easter(year)
    holidays = {
      :nyarsdagen => Date.new(year,1,1),
      :trettondagen => Date.new(year,1,6),
      :langfredag => easter-2,
      :paskdagen => easter,
      :annandagpask => easter+1,
      :forstamaj => Date.new(year, 5,1),
      :kristiflygare => easter+5*7+4,
      :nationaldagen => Date.new(year,6,6),
      :midsommar => get_midsommar(year),
      :allhelgona => get_allhelgona(year),
      :juldagen => Date.new(year,12,25),
      :annandagen => Date.new(year,12,26),
    }
  end

  def self.free_dates(year)
    dates = free_days_for_year(year)
    dates.invert
  end

  def self.to_string(daysym)
    holidays = {
      :nyarsdagen => 'Nyårsdagen',
      :trettondagen => 'Trettondagen',
      :langfredag => 'Långfredag',
      :paskdagen => 'Påskdagen',
      :annandagpask => 'Annandag påsk',
      :forstamaj => 'Första maj',
      :kristiflygare => 'Kristi flygare',
      :nationaldagen => 'Sveriges nationaldag',
      :midsommar => 'Midsommardagen',
      :allhelgona => 'Alla helgons dag',
      :juldagen => 'Juldagen',
      :annandagen => 'Annandag jul',
      :julafton => 'Julafton',
      :nyarsafton => 'Nyårsafton',
      :midsommarafton => 'Midsommarafton'
    }[daysym]
  end
end
