# coding: utf-8
class CmdsPlugin < BasePlugin
  def initialize()
    @actions = ['sex', 'sexycow', 'sexyrev', 'uptime', 'cow', 'rev']#, 'cow', 'sexycow']
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
      `/usr/games/bin/sex | /usr/bin/cowsay #{eyes} -f #{FileUtils.pwd}/static/reven.cow`.each_line{|l| resp << l }
      resp
  end

    def cow(msg)
      return nil if msg.message.empty?
      resp = []
      `/usr/bin/cowsay #{msg.message.shellescape}`.each_line{|l| resp << l }
      resp
    end

    def rev(msg)
      return nil if msg.message.empty?
      resp = []
      `/usr/bin/cowsay -f #{FileUtils.pwd}/static/reven.cow #{msg.message.shellescape}`.each_line{|l| resp << l }
      resp
    end

  #class << self
    def sex(msg)
      `/usr/games/bin/sex`
    end


  #end
end
