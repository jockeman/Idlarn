
class GeckoPlugin < BasePlugin
  def initialize()
    @actions = ['gecko']
  end
  def gecko(msg)
    msg.message
  end
end
