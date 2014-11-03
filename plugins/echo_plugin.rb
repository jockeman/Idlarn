# coding: utf-8
class EchoPlugin < BasePlugin
  def initialize()
    @actions = ['echo']
  end
  def echo(msg)
    msg.message
  end
end
