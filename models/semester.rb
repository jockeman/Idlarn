class Semester < ActiveRecord::Base
  belongs_to :user

  def self.add_semester user, string
    from, till = string.split('till')
    from = Time.parse(from)
    till = Time.parse(till) if till
    till = from if till.nil?
    till = till.tomorrow if till.hour == 0
    sem = self.where(user_id: user.id).where("(starts_at BETWEEN '#{from}' AND '#{till}') OR (ends_at BETWEEN '#{from}' AND '#{till}') OR (starts_at < '#{from}' AND ends_at > '#{till}') OR (starts_at > '#{from}' AND ends_at < '#{till}')").first
    if sem
      sem.starts_at = from
      sem.ends_at = till
      sem.save
    else
      self.create :user_id => user.id, :starts_at => from, :ends_at => till if (from && till)
    end
  end

  def self.get_semesters user
    self.where("ends_at > '#{Time.now}'").where(user_id: user.id).order(:starts_at)
  end

  def self.get_current
    self.where "'#{Time.now}' BETWEEN starts_at AND ends_at"
  end

  def self.get_next_semester user
    return "s_eal har inget jobb" if user.display == 'seal'
    sem = get_semesters(user).first
    sem = sem.to_string if sem
    sem = "%s har ingen semester" % user.to_s if sem.nil?
    sem
  end

  def to_string
    return "seal har inget jobb" if self.user.display == 'seal'
    now = Time.now
    s = 0
    str = '%s har semester ' % self.user.to_s
    starts_at = self.starts_at
    starts_at-= 1.day while Hday.is_holiday(starts_at.localtime.to_date - 1)
    work_time = Work.find_by_user_id_and_workday( self.user_id, starts_at.yesterday.wday)|| Work.find_by_user_id_and_workday(self.user_id, nil) || Work.default
    starts_at-=(24-work_time.end_hour).hour-work_time.end_min.minutes if starts_at.localtime.hour == 0
    ends_at = self.ends_at
    ends_at+= 1.day while Hday.is_holiday(ends_at.to_date + 1)
    work_time = Work.find_by_user_id_and_workday( self.user_id, ends_at.yesterday.wday)|| Work.find_by_user_id_and_workday(self.user_id, nil) || Work.default
    ends_at+=(work_time.start_hour.hour + work_time.start_min.minutes) if ends_at.localtime.hour == 0
    if starts_at < now
      str+= 'i '
      slutstr = ' till.'
      s = ends_at - now
    else
      str+= 'om '
      slutstr = ''
      s = starts_at - now
    end

    d = (s / 1.days).floor
    s = s - d.days
    h = (s / 1.hours).floor
    s = s - h.hours
    m = (s / 1.minutes).floor
    s = (s - m.minutes).round
    str+="#{d} dag#{d == 1 ? '' : 'ar'}, " if d > 0
    str+="#{h} timm#{h == 1 ? 'e' : 'ar'} och " if h > 0 || d > 0
    str+="#{m} minut#{m == 1 ? '' : 'er'}"
    str+=slutstr
  end

  def to_short_string
    now = Time.now
    s = 0
    str = '%s ' % self.user.to_s
    starts_at = self.starts_at
    starts_at-= 1.day while Hday.is_holiday(starts_at.to_date - 1)
    starts_at-=7.hour if starts_at.hour == 0
    ends_at = self.ends_at
    ends_at+= 1.day while Hday.is_holiday(ends_at.to_date + 1)
    ends_at+=8.hour if ends_at.hour == 0
    if starts_at < now
      str+= ''
      slutstr = ' kvar'
      s = ends_at - now
    else
      str+= 'om '
      slutstr = ''
      s = starts_at - now
    end

    d = (s / 1.days).floor
    s = s - d.days
    h = (s / 1.hours).floor
    s = s - h.hours
    m = (s / 1.minutes).floor
    s = (s - m.minutes).round
    str+="#{d}d, " if d > 0
    str+="#{h}t, " if h > 0 || d > 0
    str+="#{m}m"
    str+=slutstr
  end

end
