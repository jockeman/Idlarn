# coding: utf-8
class HolidayPlugin < BasePlugin
  require 'date'
  def initialize()
    @actions = %w(midsommar midsommarafton midsommardagen skärtorsdag skartorsdag skärtorsdag skärtorsdagen långfredag långfredagen langfredag påskafton paskafton påskdagen paskdagen)
  end

  #class << self
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
#  end
end
