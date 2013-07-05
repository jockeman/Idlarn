# coding: utf-8
class CmdsPlugin < BasePlugin
  def initialize()
    @actions = ['sex', 'sexycow', 'sexyrev', 'uptime']#, 'cow', 'sexycow']
  end

  def uptime(msg)
    `/usr/bin/uptime`.strip
  end

  def sexycow(msg)
      resp = []
      if msg.message=~/^..$/
        eyes = "-e '" + msg.message+"'"
      else
        eyes = ''
      end
      `/usr/games/bin/sex | /usr/bin/cowsay #{eyes} -f sodomized`.each_line{|l| resp << l }
      resp
  end

  def sexyrev(msg)
      if msg.message=~/^..$/
        eyes = "-e '" + msg.message+"'"
      else
        eyes = ''
      end
      resp = []
      `/usr/games/bin/sex | /usr/bin/cowsay #{eyes} -f /home/idlarn/icf/static/reven.cow`.each_line{|l| resp << l }
      resp
  end

    def cow(msg)
      resp = []
      `/usr/bin/cowsay Mu`.each_line{|l| resp << l }
      resp
    end

  #class << self
    def sex(msg)
      `/usr/games/bin/sex`
    end


  #end
end
