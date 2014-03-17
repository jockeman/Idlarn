class Poster
  attr_accessor :irc
  def initialize(irc)
    @irc = irc
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
      while @running
        begin
          read_pic()
          sleep 1
        rescue Exception => e
          puts e
        end
      end
    end
  end

  def post(row)
    @irc.send_message("PRIVMSG #dv_bildz :%s" % row)
  end

  def read_pic()
    return if File.size("/home/idlarn/picbuff.txt") == 0
    f = File.open("/home/idlarn/picbuff.txt","r")
    lines = []
    f.each_line{|l| lines << l}
    f.close()
    f = File.open("/home/idlarn/picbuff.txt","w")
    f.truncate(0)
    f.close()
    lines.each{|l| post(l);sleep(1) }
  end

end
