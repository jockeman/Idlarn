# coding: utf-8
require 'nokogiri'
require 'open-uri'
require 'json'
require 'zlib'
class WwwebPlugin < BasePlugin
  def initialize()
    @actions = ['moln', 'vecka', 'super', 'vansbro', 'mat', 'isthatcherdeadyet', 'ismycomputeron', 'sda', 'gdq', 'agdq', 'sgdq', 'esa', 'kris', 'titelffs', 'ud', 'defcon', 'temperatur', 'namnsdag', 'excuse', 'dagensdag', 'snölol', 'varning', 'temadag']
    @actions += ['snuten', 'farbrorblå', 'polisen','aina']
    @actions += ['callme', 'classname', 'robiname']
    @actions += ['callmedock', 'hadmedock', 'classmedock', 'robimedock']
    @actions += ['callmebin', 'hadmebin', 'classmebin', 'robimebin']
    @actions += ['callmename', 'hadmename', 'classmename', 'robimename']
    @actions += ['rubrlol', 'vadspela', 'vadspelalinux']
    @actions += ['stenbocken', 'vattumannen', 'fiskarna', 'väduren', 'oxen', 'tvillingarna', 'kräftan', 'lejonet', 'jungfrun', 'vågen', 'skorpionen', 'skytten']
  end

  #class << self


    def help(msg)
      case msg.message
      when 'sda', 'gdq', 'agdq'
        resp = ["http://gamesdonequick.com/schedule"]
        build_response(resp, msg)
      else
        super
      end
    end


    def ud msg
      index = msg.message.gsub(/.* (\d+)$/, '\1').to_i
      query = URI.encode msg.message.gsub(/ \d+$/,'').strip #.squeeze.strip
      puts [index, query].inspect
      doc = open "http://www.urbandictionary.com/define.php?term=#{query}"
      nok = Nokogiri::HTML doc.read
      definitions = nok.xpath("//div[@class='def-panel']")
      maxdef = definitions.length-1
      index = [maxdef, index].min
      #"[#{index}/#{maxdef}] " + definitions[index].children.map{|c| c.text}.join
      "[#{index}/#{maxdef}] " + definitions[index].xpath("div[@class='meaning']").text.strip

    end

    def defcon msg
      doc = open "http://defconwarningsystem.com"
      nok = Nokogiri::HTML doc.read
      nok.xpath("//p[@align='center']").map{|n| n.children.text.scan(/DEFCON \d/)}.flatten.compact.uniq
    end

    def vansbro msg
      doc = Nokogiri::HTML(open("http://vansbro.doppio.se").read)
      temp = doc.xpath('//div[@id="block-vansbro-api-vattentemp"]/div/div/span').children.first.to_s
      "Det är #{temp} grader i vattnet"
    end

    def vadspelalinux msg
      "nethack"
    end

    def vadspela msg
      u = msg.user.dbuser
      if msg.message.length > 0
          username = msg.message
          msg.user.dbuser.steamid = username
          msg.user.dbuser.save
          u = msg.user.dbuser
      end
      #get steamid
      return "Jag vet inte vad du har för steamid" if u.steamid.nil?
      url = "http://whatshouldiplayonsteam.com/"
      if(u.steamid.match(/^\d+$/))
        url+="profiles/"+u.steamid
      else
        url+="id/"+u.steamid
      end
      doc = Nokogiri::HTML(open(url).read)
      "Du kan väl spela " + doc.xpath("//img").last["alt"].gsub(/^'/,"").gsub(/' logo/,"")
    end

    def moln msg
    #  puts 'Moln'
    #  doc = Nokogiri::HTML(open("http://molnmolnmoln.se").read)
    #  m = doc.xpath('//div[@id="cloudlasse"]/h1').children.to_s
      #m = `wget -O - --quiet http://www.idg.se | tr -s ' ' '\n' | grep -c 'moln'`.strip
      m = `links -dump http://www.idg.se | tr -s ' ' '\n' | grep -c 'moln'`.strip
      resp = "Det är #{m} moln idag."
    end

    def isthatcherdeadyet msg
      doc = Nokogiri::HTML(open("http://www.isthatcherdeadyet.co.uk").read)
      doc.xpath('//strong[@id="dead"]').first.children.first.text
    end

    def super msg
      puts 'Super'
      doc = Nokogiri::HTML(open("http://supersupersupersuper.com/").read)
      s = doc.xpath('//div[@class="supernumber"]').children.to_s
      resp = "#{s} st super nu!"
    end

    def ismycomputeron msg
      puts 'On'
      doc = Nokogiri::HTML(open("http://www.ismycomputeron.com/").read)
      s = doc.xpath('//font').children.to_s
      resp = "#{s}"
    end

    def vecka msg
      puts 'Vecka'
      #doc = Nokogiri::HTML(open("http://vecka.nu").read)
      #m = doc.xpath('//div[@id="hoz"]/div').children.to_s
      m = DateTime.now.cweek
      resp = "Det är vecka #{m}."
    end

    def sda msg
      puts 'sda'
      begin
        uri = 'https://gamesdonequick.com/schedule'
        doc = Nokogiri::HTML(open(uri).read)
      rescue
        uri = 'http://gamesdonequick.com/schedule'
        doc = Nokogiri::HTML(open(uri).read)
      end
      rows = doc.xpath(
        "//table[@id='runTable']/tbody/tr[contains(@class, 'second-row')]")
      list = rows.map do |r|
        node = r.previous
                .previous
                .xpath("td[contains(@class, 'start-time')]")
                .first
        entry = { time: Time.parse(node.text) }
        node = node.next.next
        entry[:game] = node.text.strip if node.text
        node = node.next.next
        entry[:runner] = node.text.strip if node.text
        node = node.next.next
        entry[:setup] = node.text.strip if node.text
        node2 = r.xpath('td')
        entry[:runtime] = node2[0].text.strip if node2[0].text
        entry[:cat] = node2[1].text.strip if node2[1].text
        entry
      end

      hits = []
      if !msg.message.empty?
        search = list.select do |r|
          (!r[:game].nil? &&
            r[:game].downcase.match(msg.message.downcase) ||
          !r[:cat].nil? &&
            r[:cat].downcase.match(msg.message.downcase))
        end
        now = search.select { |r| r[:time] < Time.now }.last
        nex = search.select { |r| r[:time] > Time.now }.first
        hits = search[0..4]
      else
        now = list.select { |r| r[:time] < Time.now }.last
        nex = list.select { |r| r[:time] > Time.now }.first
        hits = [now, nex]
      end
      basestr = '[%s] %s - %s, Tid: %s %s'
      hits.compact.map do |h|
        basestr % [
          stringifytime(h[:time]),
          h[:game],
          h[:runner],
          h[:runtime],
          h[:cat]
        ]
      end
    end

    alias gdq sda
    alias agdq sda
    alias sgdq sda

    def esa msg
      puts 'esa'
      #uri = 'https://horaro.org/preesa/schedule'
      uri = 'http://www.esamarathon.com/schedule'
      doc = Nokogiri::HTML(open(uri).read)
      rows = doc.xpath '//tr'
      list = rows.map do |row|
        next unless row.children[0] && row.children[0].child
        timestring = row.children[0].child['datetime']
        next unless timestring
        time = Time.parse(timestring)
        game = row.children[1].child.text
        runner = row.children[3].child && row.children[3].child.text
#        estimate = row.children[5].child.child.to_s
        estimate = row.attributes['title'].text.split(";").first.split(": ").last
        extra = row.children[2].child.text
        [time, game, runner, estimate, extra]
      end.compact

      hits = []
      if !msg.message.empty?
        search = list.select{|r| !r.empty? && (!r[1].nil? && r[1].downcase.match(msg.message.downcase) || !r[4].nil? && r[4].downcase.match(msg.message.downcase))}
        now = search.select{|r| !r.empty? && r[0] < Time.now}.last
        nex = search.select{|r| !r.empty? && r[0] > Time.now}.first
        hits = search[0..4]
      else
        now = list.select{|r| !r.empty? && r[0] < Time.now}.last
        nex = list.select{|r| !r.empty? && r[0] > Time.now}.first
        hits = [now, nex]
      end
      basestr = "[%s] %s - %s, Tid: %s %s"
      nowstr = basestr % [stringifytime(now[0]), now[1], now[2], now[3], now[4]] if now
      #nowstr = "Nu: #{now[1]} - #{now[2]}, Tid: #{now[3]}"
      nextstr = basestr % [stringifytime(nex[0]), nex[1], nex[2], nex[3], nex[4]] if nex
      strs = hits.compact.map{|h| basestr % [stringifytime(h[0]), h[1], h[2], h[3], h[4]]}
      #nextstr = "[#{nex[0].strftime "%H:%M"}] #{nex[1]} - #{nex[2]}, Tid: #{nex[3]}"
#      "Now playing: #{now[1]}. Upcoming: [#{nex[0].strftime "%H:%M"}] #{nex[1]}"
      return strs
      return [nowstr.strip, nextstr.strip] if nowstr && nextstr
      return nowstr.strip if nowstr
      return nextstr.strip if nextstr
    end

    def stringifytime(time)
      if time.to_date == Date.today
        time.localtime.strftime("%H:%M")
      else
        time.localtime.strftime("%d/%m %H:%M")
      end
    end

    def stenbocken msg
      horoskop('stenbocken')
    end
   
    def vattumannen msg
      horoskop('vattumannen')
    end
   
    def fiskarna msg
      horoskop('fiskarna')
    end
  
    def väduren msg
      horoskop('vaduren')
    end
     
    def oxen msg
      horoskop('oxen')
    end
   
    def tvillingarna msg
      horoskop('tvillingarna')
    end
   
    def kräftan msg
      horoskop('kraftan')
    end
   
    def lejonet msg
      horoskop('lejonet')
    end
   
    def jungfrun msg
      horoskop('jungfrun')
    end
   
    def vågen msg
      horoskop('vagen')
    end
   
    def skorpionen msg
      horoskop('skorpionen')
    end
   
    def skytten msg
      horoskop('skytten')
    end
   
    def horoskop(sign)
      doc = Nokogiri::HTML(open("http://www.passagen.se/horoskop/#{sign}").read)
      resp = doc.xpath('//div[@class="horoscope-starsign-daily"]/p').children.to_s
      resp.gsub(/  +/,' ').gsub(/\n/,'')
    end

    def mat(msg)
      return
      uri = URI('http://www.vadihelveteskajaglagatillmiddag.nu/')
      if msg.message == 'gräs'
        uri.path = uri.path+'vegan'
      end
      doc = Nokogiri::HTML(open(uri).read)
      path = doc.xpath('//a').first.attributes['href'].value
      name =  doc.xpath('//a').first.children.to_s
      ["DU KAN FÖR I HELVETE LAGA LITE... #{name}", path]
    end

    def kris(msg)
      if !msg.message.empty?
        i = msg.message.to_i
      else
        i = 1
      end
      entries = JSON.parse(open('http://api.krisinformation.se/v1/feed?format=json').read)
      entry = entries["Entries"][i-1]
      plats = entry["CapArea"].map{|c| c["CapAreaDesc"]}.join(", ") 
      summary = entry["Summary"]
      updated = entry["Updated"]
      "[%d/%d][%s] %s" % [i, entries["Entries"].length,plats, summary]
    end

    def titelffs(msg)
      if !msg.message.empty?
        u = User.fetch msg.message, false
        if u
          page = 'http://'+Url.find_by_channel_and_user_id(msg.channel, u.id, :order => "created_at DESC").url
        else
          page = msg.message
        end
      else
        page = 'http://'+Url.find_by_channel(msg.channel, :order => "created_at DESC").url if page.nil?
      end
      begin
        doc = open(page)
      rescue
        doc = open(page.sub(/http/,'https'))
      end
      nok = Nokogiri::HTML(doc.read)
      nok.xpath('//title').first.child.text.strip
    end

    def temperatur(msg)
      doc = Nokogiri::HTML(open('http://130.238.141.28/obs_10min.htm'))
      varr = doc.xpath('//pre').text.gsub(/  */," ").split("\r\n")
      #varr[1].split(":").last.strip
      [varr[0], varr[3], varr[4], varr[5], varr[6]].join(", ")
    end

    def rubrlol(msg)
      doc = Nokogiri::HTML(open('http://www.rubrikgeneratorn.se'))
      varr = doc.xpath('//body/div').children.first.text
      #varr[1].split(":").last.strip
      varr
    end
    
    def snölol(msg)
      doc = Nokogiri::HTML(open('http://celsius.met.uu.se/uppsala/obs.htm'))
      varr = doc.xpath('//pre').text.gsub(/  */," ").split("\r\n")
      #varr[1].split(":").last.strip
      [varr[10]].join(", ")
    end
    
    def namnsdag(msg)
      doc = Nokogiri::HTML(open('http://www.lysator.liu.se/alma/alma.cgi'))
      dinfo = doc.xpath("//table/tr[@class='v today']/td[@class='vnames rightmost']").children
        namn = dinfo.last.text.split(',').map{|s| s.strip}.join(' och ')
      if dinfo.count == 1
        return "Idag har "+ namn + "namnsdag."
      else
        dagen = dinfo.first.text
        return "Idag är det " + dagen + " och " + namn + "har namnsdag"
      end
    end

    def excuse(msg)
      doc = Nokogiri::HTML(open('http://developerexcuses.com'))
      doc.xpath("//center/a").children.text
    end

    def classname(msg)
      doc = Nokogiri::HTML(open('http://www.classnamer.com/'))
      doc.xpath("//p[@id='classname']").text
    end

    def robiname(msg)
      "Holy %s, Batman!" % classname(msg)
    end

    def dagensdag(msg)
      if msg.message.empty?
        dagen = Date.today
      else
        dagen = Date.parse(msg.message) rescue Date.today
      end
      doc = Nokogiri::HTML(open('http://temadagar.se/kalender'))
      dagar = doc.xpath('//p')[4..-5]
      full = dagar.map do |d| 
        datum = d.xpath('b').text
        next nil if datum.nil? || datum.empty?
        days = d.children.map{|c| c.text}
        days.compact!
        days.select!{|s| s.length > 2}
        [Date.parse(englishify_date(datum))] + days[1..-1] 
      end.compact
      #full = doc.xpath("//p[4]").children.map{|c| c.text}
      #full = full.map{|t| t.empty? ? "\n": t}.join.split("\n")
      #f = open('static/temadagar-2013.csv')
      #full = f.map{|r| 
      #  row = r.split(';')
      #  row[0] = Date.parse(row[0])
      #  row
      #}
      dagar = full.inject({}){ |dict, elem| 
      #  if not elem.split.first.nil?
      #    date = Date.parse(elem.split.first) rescue nil
      #    dict[date] = [] if date and dict[date].nil?
      #    dict[date] << elem.split[1..-1].join(" ") unless date.nil?
      #  end
        elem[1..-1].each{|e| e.strip!}
        dict[elem[0]] = elem[1..-1]
        dict
        }
      dagar[dagen] || ["Alla Egurtars dag", "Egurtdagen", "Internationella dagen för egurtar"][Zlib.crc32(dagen.to_s)%3]
    end

    alias :temadag :dagensdag

    def englishify_date(date)
      date.sub!(/Maj/,'May')
      date.sub!(/Juni/,'June')
      date.sub!(/Juli/,'July')
      date.sub!(/Augusti/,'August')
      date.sub!(/Oktober/,'October')
      return date
    end

    def varning(msg)
      klass = "smhi_alla_varningar"
      if !msg.message.empty?
        #klass = "smhi_varningar_klass%d" % msg.message
        i = msg.message.to_i
      else
        i = 1
      end
      doc = Nokogiri::HTML(open("http://www.smhi.se/weatherSMHI2/varningar/%s.xml" % klass))
      warnings = doc.xpath('//item')
      warning = warnings[i-1]
      time = Time.parse(warning.xpath('pubdate').text.strip).strftime("%Y-%m-%d %H:%M")
      header = warning.xpath('title').text.strip
      title = "[%d/%d] %s %s" % [i, warnings.length, time, header]
      description = warning.xpath('description').text.strip
      [title, description]
    end

    def snuten(msg)
      if !msg.message.empty?
        i = msg.message.to_i
      else
        i = 1
      end
      site = open("https://polisen.se/Uppsala_lan/Aktuellt/RSS/Lokal-RSS---Handelser/Lokala-RSS-listor1/Handelser-RSS---Uppsala-lan/?feed=rss")
      doc = Nokogiri::HTML(site)
      puts "nil!!!" if doc.nil?
      snuten = doc.xpath('//item') 
      snut = snuten[i-1]
      puts site.inspect if snut.nil?
      title = "[%d/%d] %s" % [i, snuten.length, snut.xpath('title').text.strip]
      description = snut.xpath('description').text.strip
      [title, description]
    end

    alias :polisen :snuten
    alias :farbrorblå :snuten
    alias :aina :snuten

    def callverb()
      def Choose(arr)
        return arr[(rand()*arr.length).floor]
      end
      Choose(['slap','fuck','spank','smack',
     'pinch','rub','mock','squeeze','suck','bite',
     'bite off','chew','lick','flap','stroke',
     'touch','smell','sniff','jizz on','rub one out on',
     'wank to','shit on','piss on','paint','fist',
     'scratch','screw','kiss','finger','jiggle',
     'tickle','hold','grab','blow on','scream at',
     'befriend','write a book about','sue','marry',
     'rape','make love to','pepper','twist','tenderize',
     'spit on','fart on','meet','spend a charming afternoon with',
     'introduce your sister to','sandwich','write fanfic about',
     'blog about','let\'s have a minute of silence for','listen to',
     'google','stick your dick in','prance around in',
     'make your way inside','plunder','swiggity','eat',
     'stuff','hump','humiliate','blow','blow up','fancy',
     'berate','rate','rustle'])
    end
    def callsub()
      def Choose(arr)
        return arr[(rand()*arr.length).floor]
      end
      Choose(['tits',
     'ass','dick','mouth','face','balls','cock','crotch',
     'face','beard','moustache','buns','boobs','boobies',
     'breasts','chest','butt','buttocks','nips','nipples',
     'vag','snatch','cunt','fanny','skirt','pants','panties',
     'loins','undies','bra','shorts','jimmies','crack',
     'thighs','rump','arse','feet','nuts','cat','horse',
     'goat','dog','parrot','steak','cheese','hose','goatee',
     'sideburns','sandwich','booty','mother','father',
     'grand-parents','neighbor','shiggity','dinner','shizzle',
     'bunny','evil twin','thing','pickle','nutsack'])
    end

    def callname()
      def Choose(arr)
        return arr[(rand()*arr.length).floor]
      end
      Choose([
     'Shirley','Sally','Dolly','Pedro','Jose','Juanita',
     'Sharon','Geoffrey','Susan','Mary','Stanley','Bradley',
     'Barney','Brandon','Milford','Robert','Rosie','Steve',
     'Patrick','Jeffrey','Brian','David','Santa','Batman',
     'mommy','daddy','grandpa','grandma','auntie','uncle',
     'pretty','maybe','when you\'re home','when you\'re done','darling','fabulous'])
    end

    def _callme(verb, subst, name)
     'Well '+ verb+ ' my '+ subst + ' and call me '+ name
    end
    def _haddock()
      Haddock.order('RANDOM()').first.insult.strip.downcase
    end
    def _robin()
      Robin.order('RANDOM()').first.comment
    end

    def robimedock(msg)
      _callme(callverb(), _robin(), _haddock())
    end
    def callmebin(msg)
      _callme(callverb(), _robin(), callname())
    end

    def classmedock(msg)
      c = classname(msg)
      h2 = _haddock()
      _callme(callverb(), c, h2.downcase)
    end

    def hadmedock(msg)
      h = _haddock
      h2 = _haddock
      _callme(callverb(), h.downcase, h2.downcase)
    end

    def callmedock(msg)
      h = _haddock
      _callme(callverb(), callsub(), h.downcase)
    end
    def hadmebin(msg)
      _callme(callverb(), _haddock, _robin)
    end
    def classmebin(msg)
      _callme(callverb(), classname(msg), _robin)
    end
    def robimebin(msg)
      _callme(callverb(), _robin, _robin)
    end
    def callmename(msg)
      _callme(callverb(), callsub(), classname(msg))
    end
    def hadmename(msg)
      _callme(callverb(), _haddock, classname(msg))
    end
    def classmename(msg)
      _callme(callverb(), classname(msg), classname(msg))
    end
    def robimename(msg)
      _callme(callverb(), _robin, classname(msg))
    end


    def callme(msg)
     _callme(callverb(), callsub(), callname())
    end
end
