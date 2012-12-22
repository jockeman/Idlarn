# coding: utf-8
class EchoPlugin < BasePlugin
  def initialize()
    @actions = ['kossa']
  end
  def echo(msg)
    `cowsay #{msg.message}`
  end
end
