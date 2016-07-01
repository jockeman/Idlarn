class Katt < ActiveRecord::Base

  def self.spara(kattskemt)
    self.find_or_create_by skemt: kattskemt.downcase
  end

  def self.dra(del=nil)
    if del
      self.where("skemt like '%#{del}%'").order('RANDOM()').first
    else
      self.order('RANDOM()').first
    end.skemt
  end

end
