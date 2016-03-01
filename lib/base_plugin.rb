# coding: utf-8
class BasePlugin
  attr_reader :actions, :regexps
  attr_accessor :nick
  def initialize()
    @actions = []
    @regexps = []
    @plugins = {}
  end

  def help(message)
    plugin = @plugins[message.message]
    if plugin
      resp = ".#{message.message}"
      resp+= plugin[:params].each{|k,v| "%s %s" % [k, v]}
    else
      resp = "Finns ingen hjälp för #{message.message}"
    end
    build_response(resp, message)
  end

  def action(message)
    begin
      if @plugins && @plugins[message.action.to_sym]
        perform_action(message)
      elsif @actions.include?(message.action)
        resp = self.send(message.action, message)
        build_response(resp, message)
      end
    rescue StandardError => e
      puts [e.message, e.backtrace]
    end
  end

private
  def build_response resp, message, opts={}
    #@nick = "SkreddarN"
    resp = resp.split("\n") if resp.class == String
    if message.channel!=@nick
      resp_to = message.channel
      opts[:priv]|= false
    else
      resp_to = message.user.nick
      opts[:priv]|= true
    end
    resp = [resp] unless resp.class == Array
    resp = resp.map{|r| r.gsub("%self", @nick)}
    resp.map{|r| Outgoing.new(resp_to, r.rstrip, opts)}
  end

  def reg_action action, params={}, &block
    @actions << action.to_s
    @plugins[action] = {:body => block}
    @plugins[action].update({:params => params})
  end

  def perform_action(message)
    plugin = @plugins[message.action.to_sym]
    resp = plugin[:body].yield message
    build_response(resp, message)
  end
end
