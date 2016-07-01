# coding: utf-8
class EventPlugin < BasePlugin
  def initialize()
    @actions = ['remember', 'random', 'forget', 'undo', 'redo', 'default', 'datum', 'lon', 'lön', 'next', 'list', 'saker', 'nästa', 'fredag', 'friday', 'events', 'history', 'idag', 'omsen', 'lån', 'födelsedag', 'nästa_födelsedag', 'age', 'ålder']
    @actions+=['tisdag','onsdag','torsdag','lördag','söndag']
  end

  #class << self
    def action(msg)
      if @actions.include? msg.action
        super
      else
        resp = Event.naer msg.action.downcase rescue return nil
        build_response(resp, msg)
      end
    end

    def events(msg)
      if msg.message && msg.message.length > 0
        events = Event.where(in_use: true).order(:key).where("key ilike '%#{msg.message}%'").limit(6)
      else
        events = Event.count :conditions => "in_use = TRUE", :group => :key#find_all_by_in_use true, :order => :key
        return "Det finns #{events} nycklar, använd .events <delnyckel> för att söka."
      end
      events[5].key= "..." if events.length > 5
      resp = events.map{|e| e.key}.join(', ')
    end

    def next(msg)
      Event.list.first.to_string
    end
    alias :nästa :next

    def idag(msg)
      e = Event.list.first
      if e.startar.to_date == Date.today
        e.to_string
      else
        "Idag är det ingen dag"
      end
    end

    def list(msg)
      es = Event.list
      es = es.select{|e| e.key!= 'fika' && e.key!= 'lunch'}
      es[0..4].map{|e| e.to_string}.join(' | ')
    end
    alias :saker :list

    def datum(msg)
      if msg.message.empty?
        return Time.now.to_s
      end
      #TimeParser.parse_ex(msg.message).to_s
      TimeParser.get_date(msg.message).to_s
    end
    
    def omsen(msg)
      TimeParser.get_date(msg.message).to_date.omsen.strip.capitalize
    end

    def lon(msg)
      datum, kvar = nil, 0
      d = msg.user.dbuser.payday
      if msg.message=~/@(\d*)/u
        d = $1.to_i
        msg.user.dbuser.payday = d
        msg.user.dbuser.save
      end
      message = msg.message.gsub(/@(\d*)/u, '')
      if message.length > 0
        if message.strip.to_i.to_s == message.strip
          kvar = message.to_i
        else
          kvar = "NaN"
        end
      end
      datum = lond(d)
      omsenlon(datum, kvar)
    end
    alias :lön :lon

    def la_n(msg)
      input = msg.message.split.map{|m| m.to_f}
      lan = input.max
      avbet = input.min
      months = (lan/avbet).ceil
      y = months / 12
      m = months % 12
      print [lan, avbet, months, y, m].inspect
      if y > 0 && m > 0
        "Det kommer ta dig %d år och %d månader att bli skuldfri" % [y, m]
      elsif y > 0
        "Det kommer ta dig %d år att bli skuldfri" % [y]
      elsif m > 0
        "Det kommer ta dig %d månader att bli skuldfri" % [m]
      else
        nil
      end
    end
    alias :lån :la_n

    def friday(msg)
      return "It's Friday, Friday. Gotta get down on Friday. Everybody's lookin' forward to the weekend, weekend." if Date.today.friday?
      return "After Friday comes Saturday!" if Date.today.saturday?
      return "Lillfredag idag \\o/" if Hday.is_holiday(Date.today + 1)
      return "Nopp :("
    end

    def fredag(msg)
      return "Det är fredag, fredag. Måste få ner på fredag. Alla tittar fram till helgen, helgen." if Time.now.friday?
      friday(msg)
    end

    def tisdag(msg)
      return "Japp" if Time.now.tuesday?
      return "Nix"
    end
    def onsdag(msg)
      return "Japp" if Time.now.wednesday?
      return "Nix"
    end
    def torsdag(msg)
      return "Japp" if Time.now.thursday?
      return "Nix"
    end
    def lördag(msg)
      return "Japp" if Time.now.saturday?
      return "Mja, men lillörda" if Time.now.wednesday?
      return "Nix"
    end
    def söndag(msg)
      return "Japp" if Time.now.sunday?
      return "Nix"
    end
    #alias :fredag :friday

    def lond(d=25)
      month=Date.today.month
      sdate = Date.new(Date.today.year, month, d)
      sdate = sdate.next_month while sdate < Date.today
      sdate-=1 while Hday.is_holiday(sdate)
      sdate
    end

    def omsenlon(date, kvar=0)
      nu = Date.today
      if nu == date
        "Löning idag \\o/"
      else 
        dagar = (date - nu).to_i
        if kvar == "NaN"
          "Du får leva på NaN-bröd till nästa löning"
        elsif kvar > 0
          pd = kvar / dagar
          pd = "ÖVER NIO TUSEN" if pd > 9000
          "Nästa lön kommer #{date.to_s}, du har #{pd} pengaenheter att spendera på sprit o horer per dag."
        else
          "Nästa lön kommer om #{dagar} dagar."
        end
      end
    end

    def remember(msg)
      Event.remember msg.user.dbuser, msg.message.split.first, msg.message.split[1..-1].join(' ')
    end

    def random(msg)
      Event.random
    end

    def forget(msg)
      Event.forget msg.message.split.first
    end

    def undo(msg)
      Event.undo msg.message.split.first
    end

    def redo(msg)
      Event.redo msg.message.split.first
    end

    def history(msg)
      es = Event.where(key: msg.message.split.first).order(:created_at)
      es.map{|e| ((e.in_use ? "=> " : "   ") +e.to_string+(e.user ? " ["+e.user.to_s+"]" : "") + (e.created_at ? " (" + e.created_at.strftime("%Y-%m-%d") + ")" : ""))}.uniq
    end

    def birthdays(msg)
      if msg.message.empty?
        users = User.where("extract(MONTH from birthdate) = #{Date.today.month} AND extract(DAY FROM birthdate) = #{Date.today.day}")
        if users.empty?
          "Jag känner ingen som fyller år idag. :("
        else
          "Hipp! Hipp! Hurra! För " + users.map{|u| u.to_s}.join(" och ") + "!"
        end
      else
        user = User.fetch msg.message, false
        if user.birthdate
          "%s fyller år %s" % [ user.to_s, user.birthdate.strftime("%d/%m")]
        else
          "Jag vet inte när %s fyller år" % user.to_s
        end
      end
    end
    alias :födelsedag :birthdays


    def next_birthdays(msg)
      day = Date.today
      users = []
      loop do
        users = User.where("extract(MONTH from birthdate) = #{day.month} AND extract(DAY FROM birthdate) = #{day.day}")
        break if !users.empty? || day > Date.today.months_since(12)
        day = day + 1
      end
      return "Jag känner ingen som fyller år. :(" if users.empty?
      "Nästa att fylla år är: " + users.map{|u| u.to_s}.join(" och ") + ', ' + users.first.birthdate.strftime("%-d/%-m")
    end
    alias :nästa_födelsedag :next_birthdays

    def age(msg)
      if msg.message.empty?
        user = msg.user.dbuser
      else
        user = User.fetch msg.message, false
      end
      if user.birthdate
        years = 0
        now = Date.today.to_datetime
        while(now.years_ago(1) > user.birthdate)
          years +=1
          now = now.years_ago(1)
        end
        days = (now - user.birthdate.to_datetime).to_i
        "%s är %s år och %s dagar" % [ user.to_s, years, days]
      else
        "Jag vet inte när %s är född" % user.to_s
      end
    end
    alias :ålder :age
#  end
end
