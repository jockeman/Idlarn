# coding: utf-8
class TelePlugin < BasePlugin
  def initialize()
    @actions = ['telehomo', 'telefon', 'tele']
    @regexps = [/([^\d]|^)(0|\+46)(18\d{6}|7\d{6,8}|8\d{7})([^\d]|$)/u]
  end

#  class << self
    def action(msg)
      if msg.action
        super
      else
        resp = telefon(msg)
        build_response(resp, msg)
      end
    end

    def telefon(msg)
      'http://www.telehomo.se'
    end
    alias :tele :telefon
    alias :telehomo :telefon
#  end
end
