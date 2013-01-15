# coding: utf-8
class EventPlugin < BasePlugin
  def initialize()
    @actions = ['remember', 'random', 'forget', 'undo', 'redo', 'default', 'datum', 'lon', 'lön', 'next', 'list', 'saker', 'nästa', 'fredag', 'friday', 'events', 'history']
  end

  #class << self
    def action(msg)
      if @actions.include? msg.action
        super
      else
        resp = Event.naer msg.action rescue return nil
        build_response(resp, msg)
      end
    end

    def events(msg)
      if msg.message && msg.message.length > 0
        events = Event.find_all_by_in_use true, :order => :key, :conditions => "key ilike '%#{msg.message}%'", :limit => 6
      else
        events = Event.count :conditions => "in_use = TRUE"#find_all_by_in_use true, :order => :key
        return "Det finns #{events} nycklar, använd .events <delnyckel> för att söka."
      end
      events[5].key= "..." if events.length > 5
      resp = events.map{|e| e.key}.join(', ')
    end

    def next(msg)
      Event.list.first.to_string
    end
    alias :nästa :next

    def list(msg)
      es = Event.list
      es = es.select{|e| e.key!= 'fika' && e.key!= 'lunch'}
      es[0..4].map{|e| e.to_string}.join(' | ')
    end
    alias :saker :list

    def datum(msg)
      TimeParser.parse_ex(msg.message).to_s
      #TimeParser.get_date(msg.message)
    end

    def lon(msg)
      datum, kvar = nil, 0
      d = 25
      if msg.message=~/@(\d*)/u
        d = $1.to_i
      end
      message = msg.message.gsub(/@(\d*)/u, '')
      kvar = message.to_i
      datum = lond(d)
      omsen(datum, kvar)
    end
    alias :lön :lon

    def friday(msg)
      return "It's Friday, Friday. Gotta get down on Friday. Everybody's lookin' forward to the weekend, weekend." if Date.today.friday?
      return "After Friday comes Saturday!" if Date.today.saturday?
      return "Lillfredag idag \\o/" if Hday.is_holiday(Date.today + 1)
      return "Nopp :("
    end
    alias :fredag :friday

    def lond(d=25)
      month=Date.today.month
      sdate = Date.new(Date.today.year, month, d)
      sdate = sdate.next_month while sdate < Date.today
      sdate-=1 while Hday.is_holiday(sdate)
      sdate
    end

    def omsen(date, kvar=0)
      nu = Date.today
      if nu == date
        "Löning idag \o/"
      else 
        dagar = (date - nu).to_i
        if kvar > 0
          pd = kvar / dagar
          pd = "ÖVER NIO TUSEN" if pd > 9000
          "Nästa lön kommer #{date.to_s}, du har #{pd} pengaenheter att leva på per dag."
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
      es = Event.find_all_by_key msg.message.split.first, :order => :created_at
      es.map{|e| ((e.in_use ? "=> " : "   ") +e.to_string)}.uniq
    end
#  end
end
