# coding: utf-8
class HaddockPlugin < BasePlugin
  def initialize()
    @actions = ['haddock', 'insult', 'addinsult', 'robin', 'hylla', 'addhyllning']
    @regexps = []
  end

#  class << self
    def haddock(msg)
      h = Haddock.find :first, :order => 'RANDOM()'
      h.insult if h
    end

    def robin(msg)
      h = Robin.find :first, :order => 'RANDOM()'
      "Holy %s, %s!" % [h.comment, 'Batman'] if h
    end

    def insult(msg)
      return nil unless msg.message 
      return nil if msg.message.empty?
      ins = Insult.find :first, :order => 'RANDOM()'
      ins.insult % msg.message if ins
    end

    def addinsult(msg)
      return nil unless msg.message
      ins = Insult.create :insult => msg.message
      ins.insult % msg.user.nick
    end

    def hylla(msg)
      return nil unless msg.message 
      return nil if msg.message.empty?
      ins = Hylla.find :first, :order => 'RANDOM()'
      ins.hyllning % msg.message if ins
    end

    def addhyllning(msg)
      return nil unless msg.message
      return nil unless msg.message=~/.*%s.*/
      ins = Hylla.create :hyllning => msg.message
      ins.hyllning % msg.user.nick
    end
#  end
end
