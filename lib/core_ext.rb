class String
  def camelize
    self.split('_').map{|m| m.capitalize}.join
  end
end
class Fixnum
  def seconds
    self
  end

  def minutes
    self * 60.seconds
  end

  def hours
    self * 60.minutes
  end

  def days
    self * 24.hours
  end

  def sec_to_string
    str = ""
    d = (self / 1.days).floor
    s = self - d.days
    h = (s / 1.hours).floor
    s = s - h.hours
    m = (s / 1.minutes).floor
    s = (s - m.minutes).round
    str+="#{d} dag#{d == 1 ? '' : 'ar'}, " if d > 0
    str+="#{h} timm#{h == 1 ? 'e' : 'ar'} och " if h > 0 || d > 0
    str+="#{m} minut#{m == 1 ? '' : 'er'}"
    str
  end
end

class Date
  def omsen
    t = Date.current
    if t < self
      " infaller %s, %d dagar kvar" % [self, (self-t).to_i]
    elsif t > self
      " var %s, %d dagar sedan" % [self, (t-self).to_i]
    else
      " idag!"
    end
  end
end
