# coding: utf-8
class HolidayPlugin < BasePlugin
  require 'date'
  def initialize()
    @actions = %w(fettisdag fettisdagen midsommar midsommarafton midsommardagen skärtorsdag skartorsdag skärtorsdag skärtorsdagen långfredag långfredagen langfredag påskafton paskafton påskdagen paskdagen kristiflygare nationaldagen pingst)
  end

  #class << self
  
    def fettisdag(msg)
      y = msg.message.to_i if msg.message && msg.message.length > 0
      y = Date.current.year if y.nil?
      d = Hday.get_fettisdag(y)
      "Fettisdagen" + d.omsen
    end
    alias :fettisdagen :fettisdag
    def midsommar(msg)
      y = msg.message.to_i if msg.message && msg.message.length > 0
      y = Date.current.year if y.nil?
      d = Hday.get_midsommar(y)
      d = d.prev_day
      "Midsommarafton" + d.omsen
    end
    alias :midsommarafton :midsommar

    def midsommardagen(msg)
      y = msg.message.to_i if msg.message && msg.message.length > 0
      y = Date.current.year if y.nil?
      d = Hday.get_midsommar(y)
      "Midsommardagen" + d.omsen
    end

    def paskdagen(msg)
      y = msg.message.to_i if msg.message && msg.message.length > 0
      y = Date.current.year if y.nil?
      d = Hday.get_easter(y)
      "Påskdagen" + d.omsen
    end
    alias :påskdagen :paskdagen

    def paskafton(msg)
      y = msg.message.to_i if msg.message && msg.message.length > 0
      y = Date.current.year if y.nil?
      d = Hday.get_easter(y)
      d = d.prev_day
      "Påskafton" + d.omsen
    end
    alias :påskafton :paskafton

    def langfredag(msg)
      y = msg.message.to_i if msg.message && msg.message.length > 0
      y = Date.current.year if y.nil?
      d = Hday.get_easter(y)
      d = d.prev_day(2)
      "Långfredag" + d.omsen
    end
    alias långfredag :langfredag
    alias långfredagen :langfredag

    def skartorsdag(msg)
      y = msg.message.to_i if msg.message && msg.message.length > 0
      y = Date.current.year if y.nil?
      d = Hday.get_easter(y)
      d = d.prev_day(3)
      "Skärtorsdag" + d.omsen
    end
    alias :skärtorsdag :skartorsdag
    alias :skärtorsdagen :skartorsdag

    def kristiflygare(msg)
      dhelper("Kristiflygare", msg)
    end

    def pingst(msg)
      dhelper("Pingst", msg)
    end

    def nationaldagen(msg)
      dhelper("Nationaldagen", msg)
    end

    def dhelper(day,msg)
      y = yhelper(msg)
      day +Hday.free_days_for_year(y)[day.downcase.to_sym].omsen
    end

    def yhelper(msg)
      y = msg.message.to_i if msg.message && msg.message.length > 0
      y = Date.current.year if y.nil?
      y
    end
#  end
end
