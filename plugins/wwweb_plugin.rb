# coding: utf-8
require 'nokogiri'
require 'open-uri'
class WwwebPlugin < BasePlugin
  def initialize()
    @actions = ['moln', 'vecka', 'super', 'vansbro', 'mat', 'isthatcherdeadyet', 'ismycomputeron', 'sda']
    @actions += ['stenbocken', 'vattumannen', 'fiskarna', 'väduren', 'oxen', 'tvillingarna', 'kräftan', 'lejonet', 'jungfrun', 'vågen', 'skorpionen', 'skytten']
  end

  #class << self
    def vansbro msg
      doc = Nokogiri::HTML(open("http://vansbro.doppio.se").read)
      temp = doc.xpath('//div[@id="block-vansbro-api-vattentemp"]/div/div/span').children.first.to_s
      "Det är #{temp} grader i vattnet"
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
      doc = Nokogiri::HTML(open("http://vecka.nu").read)
      m = doc.xpath('//div[@id="hoz"]/div').children.to_s
      resp = "Det är vecka #{m}."
    end

    def sda msg
      puts 'sda'
      uri = 'http://marathon.speeddemosarchive.com/schedule'
      doc = Nokogiri::HTML(open(uri).read)
      table = doc.xpath "//table[@id='runTable']/tbody"
      list = table[0].children.map{|r| r.children.map{|q| q.child.to_s}}
      list.each{|r| r[0] = Time.parse(r[0].sub(/(\d+)\/(\d+)/, '\2/\1')+"-0500")}
      now = list.select{|r| r[0] < Time.now}.last
      nex = list.select{|r| r[0] > Time.now}.first
      basestr = "[%s] %s - %s, Tid: %s %s"
      nowstr = basestr % [now[0].strftime("%H:%M"), *now[1..-1]]
      #nowstr = "Nu: #{now[1]} - #{now[2]}, Tid: #{now[3]}"
      nextstr = basestr % [nex[0].strftime("%H:%M"), *nex[1..-1]]
      #nextstr = "[#{nex[0].strftime "%H:%M"}] #{nex[1]} - #{nex[2]}, Tid: #{nex[3]}"
#      "Now playing: #{now[1]}. Upcoming: [#{nex[0].strftime "%H:%M"}] #{nex[1]}"
      [nowstr.strip, nextstr.strip]
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
      uri = URI('http://www.vadihelveteskajaglagatillmiddag.nu/')
      if msg.message == 'gräs'
        uri.path = uri.path+'vegan'
      end
      doc = Nokogiri::HTML(open(uri).read)
      path = doc.xpath('//a').first.attributes['href'].value
      name =  doc.xpath('//a').first.children.to_s
      ["DU KAN FÖR I HELVETE LAGA LITE... #{name}", path]
    end

#  end
end
