# coding: utf-8
class QuotePlugin < BasePlugin
  def initialize()
    @actions = ['addquote', 'quote']
  end
#  class << self
    def addquote(msg)
      Quote.log_quote msg.user.dbuser, msg.channel, msg.message
    end

    def quote(msg)
      Quote.get_quote msg.message
    end
#  end
end
