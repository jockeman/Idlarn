# coding: utf-8
class KattPlugin < BasePlugin
  def initialize()
    @actions = ['katt']
    @regexps = [/^[kK]att åt .*$/]
  end

#  class << self
    def action(msg)
      if msg.action
        super
      else
        resp = spara(msg)
        build_response(resp, msg)
      end
    end

    def katt(msg)
      Katt.dra( msg.message).capitalize
    end

    def spara(msg)
      Katt.spara(msg.message)
      "Hoho!"
    end


#  end
end
