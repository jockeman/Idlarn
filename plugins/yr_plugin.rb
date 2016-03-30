# coding: utf-8
require 'open-uri'
require 'dalli'
require 'nokogiri'
class YrPlugin < BasePlugin
  def initialize()
    @actions = ['yrväder']
  end
  def self.yrväder(msg)
    cache = Dalli::Client.new('localhost:11211', namespace: 'yr', expires_in: 15.minutes)
    stad_rxml = cache.get('uppsala')
    if stad_rxml.nil?
      stad_xml = open("http://www.yr.no/place/Sweden/Uppsala/Uppsala/forecast.xml").read
      cache.set('uppsala', stad_rxml)
    end
    stad_xml = Nokogiri::XML.new(stad_rxml)
  end
end
