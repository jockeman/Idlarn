class PluginManager
  def initialize
    @plugins = {}
    @regexps = {}
  end

  def handle_message message, users = {}
    plugin = @plugins[message.action] if message.action
    plugin = @plugins.select{|a,p| a.class == Regexp && message.action=~a}.values.first if plugin.nil?
    plugin = @plugins['default'] if plugin.nil? && message.action
    plugin = @regexps.select{|r,p| message.message=~r}.values.first if plugin.nil? && message.action.nil? 
    return if plugin.nil?
    response = BasePlugin.const_get(plugin).new.action(message)
  end

  def register_plugin plugin
    plugin.actions.each do |action|
      @plugins[action] = plugin.to_s
    end
    plugin.regexps.each do |regexp|
      @regexps[regexp] = plugin.to_s
    end if plugin.regexps
  end

  def load_plugin plugin
    plugin = plugin+'_plugin'
    load File.join('plugins', plugin+'.rb')
    self.register_plugin(BasePlugin.const_get(plugin.camelize).new)
  end
end
