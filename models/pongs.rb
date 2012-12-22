class Pong < ActiveRecord::Base
  belongs_to :user

  def to_s()
    "[%s] %s posted by %s at %s" % [self.pong, self.url, self.user.to_s, self.created_at.to_s]
  end

end
