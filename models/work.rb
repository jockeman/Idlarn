class Work < ActiveRecord::Base
  belongs_to :user

  def self.default
    self.new({:start_hour => 8, :end_hour => 17, :start_min => 0, :end_min => 0})
  end

  def self.register(user_id, string)
    starts, ends = string.split('-')
    start_time = Time.parse(starts)
    end_time = Time.parse(ends)
    start_hour = start_time.hour
    start_min = start_time.minute
    end_hour = end_time.hour
    end_minute = end_time.minute
  end
end
