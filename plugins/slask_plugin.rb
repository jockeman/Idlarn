# coding: utf-8
class SlaskPlugin < BasePlugin
  require 'morse'
  require 'shellwords'
  SUBEX = /^s\/.*\/.*\//
  GSUBEX = /^s\/.*\/.*\/g$/
  OMSTART = /omstart,.?$/
  MEDO = /^(.*)med ([aeiouyåäöAEIOUYÅÄÖéèûîüôÉÈÎÛÏÜÔâÂ])$/i
  MEDK = /^(.*)med ([bcdfghjklmnpqrstvwxzBCDFGHJKLMNPQRSTVWXZ])$/i
  REV = /^(.*) baklänges$/
  def initialize()
    @actions = ['rand', 'longjmp', 'stop', 'halt', 'tid', 'monday', 'måndag', 'öl', 'oel', /spa+c+e+$/, 'skrivaao', 'skrivåäö', 'åäö', 'skrivaoaueoeoe', 'punch', 'pick', 'dag', 'morse', 'rovare', 'pension', 'beatlön', 'pi', 'dopparedan','frdg', 'ångest']
    @actions += ['veme', 'vemär']
    @regexps = [SUBEX, GSUBEX, OMSTART, MEDO, MEDK, REV]
  end

  #class << self
    def action(message)
      case message.action
      when /spa+c+e+$/
        resp = space()
        build_response(resp, message)
      #when 'skrivaao'
#        build_response(['Detta är UTF-8 åäöÅÄÖ.', 'Detta är ISO-8859-15 åäöÅÄÖ.'.encode("ISO-8859-15", "UTF-8")], message) 
      else
        if message.message=~SUBEX
          build_response(sub(message), message)
        elsif message.message=~GSUBEX
          build_response(sub(message, true), message)
        elsif message.message=~MEDO
          build_response(medo(message), message)
        elsif message.message=~MEDK
          build_response(medk(message), message)
        elsif message.message=~REV
          build_response(rev(message), message)
        else
          super
        end
      end
    end

    def help(message)
      puts "halp"
      if(message.message=~MEDO)
        build_response("", message)  
      end
      super
    end

    def sub(msg, g=false)
    #  _, f, r, m = msg.message.split('/')
     # return nil unless msg.user.previous[msg.channel]=~/#{f}/
     # r = '' if r.nil?
      resp ="#{msg.user.nick} menade: " 
      #resp+=(msg.user.previous[msg.channel].sub(/#{f}/, r)) unless g
      #resp+=(msg.user.previous[msg.channel].gsub(/#{f}/, r)) if g
      puts "echo #{msg.user.previous[msg.channel].shellescape} | sed -e #{msg.message.shellescape}".strip
      sub=`echo #{msg.user.previous[msg.channel].shellescape} | sed -e #{msg.message.shellescape}`.strip
      return nil if sub == msg.user.previous[msg.channel].shellescape
      resp+sub
    #rescue StandardError => e
    #  puts e.message
    #  raise e
    end
    
    def medo(msg)
      puts "med ö"
      msg.message=~MEDO
      repl = $1
      repl = I18n.transliterate repl
      sub = $2
      repl.gsub(/[aeiouyåäö]/,sub).gsub(/[AEIOUYÅÄÖ]/,sub.upcase)
    end

    def medk(msg)
      puts "med k"
      msg.message=~MEDK
      repl = $1
      sub = $2
      repl.gsub(/[bcdfghjklmnpqrstvwxz]/,sub).gsub(/[BCDFGHJKLMNPQRSTVWXZ]/,sub.upcase)
    end

    def rev(msg)
      puts "baklänges"
      msg.message=~REV
      repl = $1
      "%s blir %s baklänges" % [repl, repl.reverse]
      repl.reverse
    end

    def pension(msg)
      name = "du"
      u = msg.user.dbuser
      if msg.message.length > 0
        if !(u = User.fetch(msg.message, false)).nil?
          print "Hittade"
          name = u.to_s
        else
          print "År"
          birthdate = DateTime.parse(msg.message)
          msg.user.dbuser.birthdate = birthdate
          msg.user.dbuser.save
          u = msg.user.dbuser
        end
      end
      birthdate = u.birthdate
      return "Jag vet inte när "+name+" är född" if birthdate.nil?
      pday = birthdate.to_datetime.next_year(65)
      nu = DateTime.now
      dd = DateTimeDiff.new(nu, pday)
      puts dd.diff.inspect
      if dd.years < 0
        dd3 = DateTimeDiff.new(pday, nu)
        dd3.diff
        return name.capitalize + " borde ha gått i pension för " + dd3.to_string + " sedan."
      end
      dd2 = DateTimeDiff.new(birthdate.to_datetime, nu)
      puts dd2.diff.inspect
      bonusstr = "."
      if (dd2.years > dd.years) or 
      (dd2.years == dd.years and dd2.months > dd.months) or
      (dd2.years == dd.years and dd2.months == dd.months and dd2.days > dd.days)
        bonusstr = ". "+name.capitalize+" är mer än halvvägs nu." 
      end
      name.capitalize + " går i pension om " + dd.to_string + bonusstr 
    end

    def ångest(msg)
      name = "du"
      u = msg.user.dbuser
      if msg.message.length > 0
        if !(u = User.fetch(msg.message, false)).nil?
          print "Hittade"
          name = u.to_s
        else
          print "År"
          birthdate = DateTime.parse(msg.message)
          msg.user.dbuser.birthdate = birthdate
          msg.user.dbuser.save
          u = msg.user.dbuser
        end
      end
      birthdate = u.birthdate
      return "Jag vet inte när "+name+" är född" if birthdate.nil?

      pday = birthdate.to_datetime.next_year(81.1)
      nu = DateTime.now
      dd = DateTimeDiff.new(nu, pday)
      puts dd.diff.inspect
      if dd.years < 0
        dd3 = DateTimeDiff.new(pday, nu)
        dd3.diff
        return name.capitalize + " borde ha dött för " + dd3.to_string + " sedan."
      end
      dd2 = DateTimeDiff.new(birthdate.to_datetime, nu)
      puts dd2.diff.inspect
      bonusstr = "."
      if (dd2.years > dd.years) or 
      (dd2.years == dd.years and dd2.months > dd.months) or
      (dd2.years == dd.years and dd2.months == dd.months and dd2.days > dd.days)
        bonusstr = ". "+name.capitalize+" är mer än halvvägs nu." 
      end
      verblist = ["dö", "kola", "trilla av pinn"]
      verb = verblist.shuffle.first
      name.capitalize + " beräknas "+ verb +" om " + dd.to_string + bonusstr 
    end
    def rovare(msg)
      rovarstr = 's/\([bcdfghjklmnpqrstvwxzBCDFGHJKLMNPQRSTVWXZ]\)/\1o\1/g'
      if msg.message.empty?
        msg.message = rovarstr
        sub(msg)
      else
        resp ="#{msg.user.nick} menade: " 
        puts "echo #{msg.message.shellescape} | sed -e #{rovarstr.shellescape}".strip
        resp+=`echo #{msg.message.shellescape} | sed -e #{rovarstr.shellescape}`.strip
        resp
      end
    end

    def skrivaao(msg)
        ['Detta är UTF-8 åäöÅÄÖ.', 'Detta är ISO-8859-15 åäöÅÄÖ.'.encode("ISO-8859-15", "UTF-8")]
    end
    alias :skrivåäö :skrivaao
    alias :åäö :skrivaao

    def skrivaoaueoeoe(msg) 
      "Detta är Danska åÅøØæÆ"
    end

    def morse(msg)
      if msg.message=~/^[.\- ]+$/
        Morse.decode msg.message
      else
        Morse.encode msg.message
      end
    end

    def dag(message)
      format = message.message.empty? ? "%A" : message.message
      Time.now.strftime format
    end

    def rand(message)
      "4"
    end

    def longjmp(msg)
      'For speed!'
    end

    def stop(msg)
      'Hammertime!'
    end

    def halt(msg)
      'Hammerzeit!'
    end

    def tid(msg)
      t = Time.now
      t.utc
      t += 3600
      it = (1000*(t.hour+(t.min+t.sec/60.0)/60.0)/24).round
      '@'+it.to_s
    end

    def beatlön(msg)
      bph = 41.666
      hp = msg.message.to_i / 173.0
      bp = hp/bph
      "Du har "+ bp.round(2).to_s + "kr i beatlön"
    end

    def monday(msg)
      return 'http://youtu.be/s22bwvHQcnc' if Time.now.monday?
      return 'Nope! \o/'
    end
    alias :måndag :monday

    def friday(msg)
      return "Det är fredag, fredag. Måste få ner på fredag. Alla tittar fram till helgen, helgen." if Time.now.friday?
      #return "It's Friday, Friday. Gotta get down on Friday. Everybody's lookin' forward to the weekend, weekend." if Time.now.friday?
      return "After Friday comes Saturday!" if Time.now.saturday?
      return "Kanske lillfredag..."#"No :("
    end

    def fredag(msg)
      return "Det är fredag, fredag. Måste få ner på fredag. Alla tittar fram till helgen, helgen." if Time.now.friday?
      friday(msg)
    end

    def frdg(msg)
      return friday(msg).gsub(/[AEIOUYÅÄÖaeiouyåäö]/,'')
    end

    def 星期五(msg)
      return "Vad fan betyder 星期五?"
    end

    def punch(msg)
      return "Det är torsdag, klart du ska ha lite punch!" if Time.now.thursday?
      return "Det är visserligen inte torsdag, men lite punch vågar man sig nog på ändå."
    end

    def oel(msg)
      case Time.now.hour
      when 0..17
        'Ikväll blir det väder, perfekt for lite öl!'
      else
        'Ikväll är det tipptopp ölväder!'
      end
    end
    alias :öl :oel

    def space()
      return 'http://spaccccccccccccccccccce.ytmnd.com/'
      return 'http://spaaaaaaaaaaaaaaaaaaaaaaaccee.com/'
    end

    def pick(msg)
      msg.message.split(' vs ').shuffle.first.strip
    end

    def veme(msg)
      return nil if msg.message.split.length != 1
      u = User.fetch msg.message.split.first, false
      return "%s -> %s" % [msg.message.split.first, u.to_s] unless u.nil?
      return "Vet inte vem som är %s" % msg.message.split.first
    end
    alias :vemär :veme

    def pi(msg)
      "3.14159265358979323846264338327950288419716939937510582097494459230781640628620899862803482534211706798214808651328230664709384460955058223172535940812848111745028410270193852110555964462294895493038196442881097566593344612847564823378678316527120190914564856692346034861045432664821339360726024914127372458700660631558817488152092096282925409171536436789259036001133053054882046652138414695194151160943305727036575959195309218611738193261179310"
    end

    def dopparedan(msg)
      daydiff = Date.new(Date.current.year,12,24) - Date.today
      daydiff = Date.new(Date.current.year+1,12,24) - Date.today if daydiff < 0
      puts daydiff
      return daydiff.to_i.to_s + "x dan före dopparedan" if daydiff > 20
      ("Idag är det " + (0...(daydiff)).map{|o| 'dan före'}.join(" ") + " dopparedan.").capitalize
    end
#  end
end
