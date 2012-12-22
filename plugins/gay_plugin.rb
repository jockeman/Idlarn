# coding: utf-8
require 'gdbm'

class GayPlugin < BasePlugin
  def initialize()
    @actions = ['gay']
  end

#  class << self
    def gay(msg)
      user = msg.message.split.first if msg.message
      user = msg.user.nick if user.nil?
      duser = user.downcase
      duser.gsub!(/[^a-z0-9åäö]/,'')
      return nil if duser.length == 0
      gaydb = init_gay()
      val = gaydb[duser]
      if val == nil
        val = '%.1f' % (rand*10)
        gaydb[duser] = val
      end
      gaydb.close
      "%s is %s HOMOHMS gay." % [user, val]
    end

  private
    def init_gay()
      GDBM.new('gay.db', 0666, GDBM::WRCREAT)
    end
#  end
end
