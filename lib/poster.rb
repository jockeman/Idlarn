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
    f.each_line{|l| lines << convert_color(l)}
    f.close()
    f = File.open("/home/idlarn/picbuff.txt","w")
    f.truncate(0)
    f.close()
    lines.each{|l| post(l);sleep(1) }
  end

  RESET = "\003"
  WHITE = "\00300"
  BLACK = "\00301"
  BLUE = "\00302"
  GREEN = "\00303"
  LIGHT_RED = "\00304"
  BROWN = "\00305"
  PURPLE = "\00306"
  ORANGE = "\00307"
  YELLOW = "\00308"
  LIGHT_GREEN = "\00309"
  CYAN = "\00310"
  LIGHT_CYAN = "\00311"
  LIGHT_BLUE = "\00312"
  PINK = "\00313"
  GREY = "\00314"
  LIGHT_GREY = "\00315"

  A_RESET = "\e[0m"
  A_WHITE = "\e[97m"
  A_BLACK = "\e[30m"
  A_BLUE = "\e[34m"
  A_GREEN = "\e[32m"
  A_LIGHT_RED = "\e[91m"
  A_BROWN = "\e[31m"
  A_PURPLE = "\e[35m"
  A_ORANGE = "\e[33m"
  A_YELLOW = "\e[93m"
  A_LIGHT_GREEN = "\e[92m"
  A_CYAN = "\e[36m"
  A_LIGHT_CYAN = "\e[96m"
  A_LIGHT_BLUE = "\e[94m"
  A_PINK = "\e[95m"
  A_GREY = "\e[90m"
  A_LIGHT_GREY = "\e[37m"

  def convert_color(l)
    l.gsub!(A_RESET, RESET)
    l.gsub!(A_WHITE, WHITE)
    l.gsub!(A_BLACK, BLACK)
    l.gsub!(A_BLUE, BLUE)
    l.gsub!(A_GREEN, GREEN)
    l.gsub!(A_LIGHT_RED, LIGHT_RED)
    l.gsub!(A_BROWN, BROWN)
    l.gsub!(A_PURPLE, PURPLE)
    l.gsub!(A_ORANGE, ORANGE)
    l.gsub!(A_YELLOW, YELLOW)
    l.gsub!(A_LIGHT_GREEN, LIGHT_GREEN)
    l.gsub!(A_CYAN, CYAN)
    l.gsub!(A_LIGHT_CYAN, LIGHT_CYAN)
    l.gsub!(A_LIGHT_BLUE, LIGHT_BLUE)
    l.gsub!(A_PINK, PINK)
    l.gsub!(A_GREY, GREY)
    l.gsub!(A_LIGHT_GREY, LIGHT_GREY)
    l.strip
  end

end
