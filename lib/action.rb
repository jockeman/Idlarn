# coding: utf-8
class Action

  def initialize(action)
    @name = action
    @description = ""
    @parameters = []
    @body = nil
  end

  def description string
    @description = string
  end

  def parameter name, type, opts={}
    @parameters << Parameter.new(name, type, opts)
  end

  def body &block
    @body = block
  end

  def perform message, env={}
    params = parse_message(message, env)
    @body.call message, *params
  end

  def help
    p_desc = @parameters.map{|p| p.desc}.join(' ')
    '.%s %s - %s' % [@name, p_desc, @description]
  end

  def parse_message message, env
    message_tokens = message.message.clone.split
    @parameters.map{|p| p.parse(message_tokens, env)}
  end

end

class Parameter
  
  def initialize(name,type,opts)
    @name = name
    @type = type
    @opts = opts
  end

  def parse(tokens, env)
    case @type
    when :string
      tokens.join(' ')
    when :nick
      tokens.delete_at(0)
    when :named
      i = tokens.index(@name.to_s)
      return unless i
      tokens.delete_at(i) #remove name
      tokens.delete_at(i) #fetch parameter value
    when :users
      env[:users]
    else 
      tokens
    end
  end

  def desc
    str = 
    case @type
    when :named
      "%s value" % [@name]
    else
      "%s" % [@name]
    end
    str = "[%s]" % str if @opts[:optional]
    str
  end

end

def register_action(action)
  a = Action.new(action)
  yield a
  a
end

def new_action
  register_action(:foo) do |a|
    a.description "Test action"
    a.parameter :user, :nick, :optional => false
    a.parameter :@adder, :named, :optional => true
    a.parameter :rest, :string
    a.body{|msg, user, adder, rest| [user, rest]}
  end
end

class Message
  attr_accessor :message
  def initialize msg
    self.message = msg
  end
end
