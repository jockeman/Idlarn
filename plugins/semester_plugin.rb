# coding: utf-8
class SemesterPlugin < BasePlugin
  def initialize()
    @actions = ['semester', 'semestrar', 'helg', 'ledig']
  end

#  class << self
    def help(msg)
      case msg.message
      when 'semester'
        resp = [".semester [nick] (visa semester)",
                ".semester [startdatum] till [slutdatum] (lägg till semester)"]
        build_response(resp, msg)
      else
        super
      end
    end

    def semestrar(msg)
      if !msg.message.empty?
        user = User.fetch(msg.message, false)
        sems = Semester.find_all_by_user_id user.id, :conditions => "ends_at > '#{Time.now}'"
        return sems.map{|s| "#{s.starts_at.to_s} - #{s.ends_at.to_s}"}.join(', ')
      end
      semestrar = Semester.get_current
      semestrar.map{|s| s.to_short_string}.join(', ')
    end

    def semester(msg)
      if msg.message.empty?
        resp = Semester.get_next_semester msg.user.dbuser
      elsif u = User.fetch(msg.message, false)
        resp = Semester.get_next_semester u
      else
        Semester.add_semester msg.user.dbuser, msg.message
        'Ok'
      end
    end

    def helg msg
      user = User.fetch(msg.message, false) || msg.user.dbuser
      work_time = Work.default #Work.find_by_user_id user.id || Work.default
      if Time.now.saturday?
        return "Det är lördag idag!"
      elsif Time.now.sunday?
        return "Det är söndag!"
      elsif Time.now.friday? && Time.now.hour > work_time.end_hour
        return "Har du inte tagit helg nu så borde du det!"
      end
      sem = Semester.get_semesters(user).first
      if sem && sem.starts_at < Time.now #Semester nu!
        return 'Du är redan ledig!'
      end
      if sem
        nesta = Date.today+5 <  sem.starts_at.to_date ? Date.today + 5 : sem.starts_at
      else 
        nesta = Date.today+5
      end
      helg = Date.today
      helg+=1 while !Hday.is_holiday(helg) && helg.to_time < nesta.to_time
      helg = helg.to_time
      helg-=(24-work_time.end_hour).hour if helg.hour == 0 
      helg = sem.starts_at if sem && helg > sem.starts_at
      (helg - Time.now).to_i.sec_to_string+ ' till nästa ledighet'
    end
    alias :ledig :helg
#  end

end
