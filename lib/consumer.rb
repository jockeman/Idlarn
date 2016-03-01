# coding: utf-8
class Consumer
  require 'fiber_pool'
  attr_accessor :irc
  attr_reader :users
  attr_accessor :fp
  MEDO = /^(.*)med ([aeiouyåäöAEIOUYÅÄÖéèûîüôÉÈÎÛÏÜÔâÂ])$/i
  MEDK = /^(.*)med ([bcdfghjklmnpqrstvwxzBCDFGHJKLMNPQRSTVWXZ])$/i
  def initialize(q, irc, plugins=nil)
    @que = q
    @irc = irc
    @users = Users.new
    @plugins = {}
    @regexps = {}
    plugins = %w(slask event quote gay wwweb urls haddock tele holiday cmds semester karma mix katt) unless plugins
    plugins.each{|p| self.load_plugin(p)}
  end

  def stop!
    @running = false
    @thr.value
  end

  def kill!
    @thr.kill
    @thr.value
  end

  def run!
    @running = true
    @thr = Thread.new do
      @fp = FiberPool.new(5)
      while @running do
        if @que.length > 0
          raw_msg = @que.delete_at(0)

          next if raw_msg.nil?
          case raw_msg.type
          when :msg
            begin
              user = @users.get(raw_msg) 
            rescue Exception => e
              puts e
              next
            end
            message = Message.new(user, raw_msg) rescue next
            begin
              @fp.spawn do
                begin
                  handle_message message
                rescue Exception => e
                  puts e
                end
              end
            rescue Exception => e
              puts e
            end
          when :nick
            @users.rename(raw_msg) rescue next
          end
        else
          sleep 0.01
        end
      end
    end
  end

  def register_plugin plugin
    plugin.actions.each do |action|
      @plugins[action] = plugin.class.to_s
    end
    plugin.regexps.each do |regexp|
      @regexps[regexp] = plugin.class.to_s
    end if plugin.regexps
  end

  def load_plugin plugin
    plugin = plugin+'_plugin'
    load File.join('plugins', plugin+'.rb')
    self.register_plugin(BasePlugin.const_get(plugin.camelize).new)
  end

  def handle_message message
    all_caps = false
    if message.action == 'help'
      if !message.message.empty?
        plugin = find_plugin message.message
        return if plugin.nil?
        p = BasePlugin.const_get(plugin).new
        p.nick = @irc.nick
        responses = p.help(message)
      else
        resp = 'Commands: ' + @plugins.map{|k, v| (k.is_a?(String) ? k : k.inspect) unless v == 'command'}.compact.sort.join(', ')
        responses = []
        maxlen = 255
        while resp.length > maxlen do
          spacei = resp.rindex(" ", maxlen)
          responses << resp[0...spacei-1]
          resp = resp[spacei+1..-1]
        end
        responses << resp
        resp_to = message.user.nick
        opts = {:priv => true}
        responses = responses.map do |resp|
          Outgoing.new(resp_to, resp, opts)
        end
      end
    else 
      all_caps = message.action && message.action.downcase != message.action
      if Date.today.day == 22 && Date.today.month == 10
        all_caps = true
      end
      message.action.downcase! if message.action
      action = message.action
      if message.action && message.message=~MEDO
        medo = $2
        message.message = message.message.gsub('med '+medo, '')
      end
      if message.action && message.message=~MEDK
        medk = $2
        message.message = message.message.gsub('med '+medk, '')
      end
      moar = false
      if message.action && message.action.match(/^mo+a+r+$/)
        message.action = 'moar'
        moar = true
        ah = ActionHistory.where("action <> 'moar'").last 
        puts ah.inspect
        message.action = ah.action
        message.message = ah.parameters
        if medo
          message.message+ 'med '+medo
        end
        if medk
          message.message+ 'med '+medk
        end
      end
      plugin = find_plugin message.action
      plugin = @regexps.select{|r,p| message.message=~r}.values.first if plugin.nil? && action.nil? 
      if plugin
        ActionHistory.create :user_id => message.user.dbid, :action => message.action, :parameters => message.message
        p = BasePlugin.const_get(plugin).new
        p.nick = @irc.nick
        responses = p.action(message) rescue nil
      end
      if moar && !responses
        responses = ["."+message.action+" "+message.message ]
        opts = {}
        if message.channel!=@irc.nick
          resp_to = message.channel
          opts[:priv]|= false
        else
          resp_to = message.user.nick
          opts[:priv]|= true
        end
        responses = responses.map do |resp|
          Outgoing.new(resp_to, resp, opts)
        end
      end
    end
    if responses
      message.user.velocity << Time.now
      message.user.velocity.delete_if{|v| (Time.now - v) > 30}
      if message.user.velocity.length > 25
        message.user.ignore = Time.now + 300
        return nil
      end
      responses = [responses] unless responses.kind_of? Array
      sleepDurr = 0
      if responses.length > 10
        sleepDurr = 0.5
      end
      responses.each do |response|
        @irc.send_message response, all_caps, medo, medk
        sleep sleepDurr
      end
    else
      message.user.previous[message.channel] = message.message
    end
  end

  def reload_users path='users'
    load File.join('lib/%s.rb' % path) rescue nil
    @users = Users.new
  end

private
  def find_plugin action
    action = action.downcase if action
    plugin = @plugins[action] if action
    plugin = @plugins.select{|a,p| a.class == Regexp && action=~a}.values.first if plugin.nil?
    plugin = @plugins['default'] if plugin.nil? && action
    plugin
  end

end
