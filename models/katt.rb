class Katt < ActiveRecord::Base

  def self.spara(kattskemt)
    self.find_or_create_by_skemt kattskemt.downcase
  end

  def self.dra(del=nil)
    if del
      self.find :first, :conditions => "skemt like '%#{del}%'", :order => 'RANDOM()'
    else
      self.find :first, :order => 'RANDOM()'
    end.skemt
  end

end
