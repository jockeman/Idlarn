# coding: utf-8
require 'gdbm'

class GayPlugin < BasePlugin
  def initialize()
    @actions = ['gay']
  end

#  class << self

    def gay(msg)
      parts = msg.message.split if msg.message
      parts = [msg.user.nick] if parts.nil? || parts.empty?
      puts parts.inspect
      vals = parts.map do |part|
        duser = part.downcase
        duser.gsub!(/[^a-z0-9åäö]/,'')
        next if duser.length == 0
        gaydb = init_gay()
        val = gaydb[duser]
        if val == nil
          val = '%.1f' % (rand*10)
          gaydb[duser] = val
        end
        gaydb.close
        val
      end
      vals.compact!
      puts vals.inspect
      puts vals.size
      val = vals.inject(0.0){ |sum, el| sum + el.to_f }.to_f / vals.size
      "%s is %s HOMOHMS gay." % [parts.join(' '), val.round(1)]
    end
#    def gay(msg)
#      user = msg.message.split.first if msg.message
#      user = msg.user.nick if user.nil?
#      duser = user.downcase
#      duser.gsub!(/[^a-z0-9åäö]/,'')
#      return nil if duser.length == 0
#      gaydb = init_gay()
#      val = gaydb[duser]
#      if val == nil
#        val = '%.1f' % (rand*10)
#        gaydb[duser] = val
#      end
#      gaydb.close
#      "%s is %s HOMOHMS gay." % [user, val]
#    end

  private
    def init_gay()
      GDBM.new('gay.db', 0666, GDBM::WRCREAT)
    end
#  end
end
