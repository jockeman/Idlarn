# coding: utf-8
class EchoPlugin < BasePlugin
  def initialize()
    @actions = ['echo']
  end
  def self.echo(msg)
    msg.message
  end
end
