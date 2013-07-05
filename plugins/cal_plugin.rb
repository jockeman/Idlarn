# coding: utf-8
class CalPlugin < BasePlugin
  def initialize()
    @actions = ['c', 'cal', 'pop', 'p']
  end

  def cal(is)
    res = 0
    is.each {|i| res = push_stack(i.to_s)}
    res
  end
  alias :c :cal
  def pop()
    gdbm = init_stack
    i= gdbm.delete((gdbm.length-1).to_s).to_s
    gdbm.close
    i
  end
  alias :p :pop
private

  def push_stack(i)
    if i.match /^[-+*\/]$/
      a = pop()
      b = pop()
      i = eval( b+i+a).to_s
    end
    if i == '^'
      a = pop().to_f
      b = pop().to_f
      i =  (b**a).to_s
    end
    if i == 'PI'
      i = Math::PI.to_s
    end
    if i.end_with? '%'
      i = (i.to_f / 100).to_s
    end
    return pop if i == 'p'
    return nil unless i.match /^-?\d+(\.\d+)?$/
    gdbm = init_stack
    gdbm[gdbm.length.to_s]=i.to_s
    gdbm.close
    nil
  end

  def init_stack()
    GDBM.new('stack.db')
  end


end
