# coding: utf-8
class BildzPlugin < BasePlugin
  def initialize()
    @actions = []
    @regexps = [/(http(s?)\:\/\/.*\.(jpe*g|gif|png))/u]
  end

  def action(msg)
    if msg.action
      super
    else
      bildr(msg)
    end
  end

  def bildr(msg)
    msg.message=~@regexps.first
    `(cd bildz; wget '#{$1}')`
    `(cd #{FileUtils.pwd}; curl #{$1} | jp2a --width=40 > picbuff.txt)`
    return nil
  end
end
