class ICF
  attr_accessor :irc
  attr_reader :consumer, :listener
  def initialize(host='irc.homelien.no', port=6667)
    @irc = IRC.new(host, port)
    @q = []
    @plugins = %w(slask event quote gay wwweb urls haddock tele holiday cmds)
    @listener = Listener.new(@q, @irc)
    @consumer = Consumer.new(@q, @irc, @plugins)
    self.run!
  end

  def stop! qmsg='Changing batteries'
    @irc.disconnect qmsg
    @listener.stop!
    @consumer.stop!
  end
  def run!
    @listener.run!
    @consumer.run!
  end

  def join(chan)
    @irc.join(chan)
  end

  def load_plugin plugin
    @consumer.load_plugin plugin
    @plugins << plugin
    @plugins.uniq!
  end

  def reload_listener!(path='listener')
    @listener.stop! if @listener
    load File.join('lib/%s.rb' % path)
    @listener = Listener.new(@q, @irc)
    @listener.run!
  end

  def reload_consumer!(path='consumer')
    @consumer.stop! if @consumer
    load File.join('lib/%s.rb' % path)
    @consumer = Consumer.new(@q, @irc, @plugins)
    @consumer.run!
  end

  def reload_irc!(host=@irc.host, port=@irc.port,path='irc')
    stop!
    load File.join('lib/%s.rb' % path) rescue nil
    @irc = IRC.new(host, port)
    @listener.irc = @irc
    @consumer.irc = @irc
    run!
  end

  def reload_plugin_manager path='plugin_manager'
    @consumer.reload_plugin_manager path
  end

  def reload_users path='users'
    @consumer.reload_users path
  end

  def say(msg, channel="dv")
    @irc.send_message(Outgoing.new(channel, msg))
  end
  
end
