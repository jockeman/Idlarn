class Job < ActiveRecord::Base
  belongs_to :user

  def self.add_job user
    
  end

  def to_s_short
    "%s - %s" % [self.place, self.tldr]
  end

  def to_s
    self.attributes.inspect
  end

end
