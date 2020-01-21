# coding: utf-8
require 'gdbm'
require 'zlib'

class GayPlugin < BasePlugin
  A = -421/5525.0; B = 2964/425.0; C = -266112/5525.0
  A1 = -87938533687/94431605510171898419461975.0; B1 = 529610498446420146604/94431605510171898419461975.0; C1 = -720041078472685432397564955264/94431605510171898419461975.0
  def initialize()
    @actions = ['amfibie', 'wt']
  end

    def g(nick)
      x = Zlib.crc32(nick) % 100
      ((A*x**2+B*x+C).round()%101)/10.0
    end

    def g2(nick)
      x = Zlib.crc32(nick)
      ((A1*x**2+B1*x+C1).round()%101)/10.0
    end

    def amfibie(msg)
      parts = msg.message.split if msg.message
      parts = [msg.user.nick] if parts.nil? || parts.empty?
      puts parts.inspect
      vals = parts.map do |part|
        duser = part.downcase
        duser.gsub!(/[^a-z0-9åäö]/,'')
        next if duser.length == 0
        val = g2(duser) #gaydb[duser]
        val
      end
      vals.compact!
      puts vals.inspect
      puts vals.size
      val = vals.inject(0.0){ |sum, el| sum + el.to_f }.to_f / vals.size
      "%s är %s%% amfibie." % [parts.join(' '), (val*10).round(0)]
    end

    def wt(msg)
      parts = msg.message.split if msg.message
      parts = [msg.user.nick] if parts.nil? || parts.empty?
      puts parts.inspect
      vals = parts.map do |part|
        duser = part.downcase
        duser.gsub!(/[^a-z0-9åäö]/,'')
        next if duser.length == 0
        wtdb = init_wt()
        val = wtdb[duser]
        if val == nil
          val = '%.1f' % (rand*10)
          wtdb[duser] = val
        end
        wtdb.close
        val
      end
      vals.compact!
      puts vals.inspect
      puts vals.size
      val = vals.inject(0.0){ |sum, el| sum + el.to_f }.to_f / vals.size
      "WT-metern visar %s megaConny för %s." % [val.round(1), parts.join(' ')]
    end

  private
    def init_wt()
      GDBM.new('wt.db', 0666, GDBM::WRCREAT)
    end
end
