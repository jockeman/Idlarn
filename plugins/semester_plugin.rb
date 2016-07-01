# coding: utf-8
class SemesterPlugin < BasePlugin
  def initialize()
    @actions = ['semester', 'semestrar', 'helg', 'ledig', 'arbetsdag']
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
      override_time = Time.parse(msg.message) rescue nil
      work_time = Work.find_by_user_id_and_workday(user.id, Date.today.wday) || Work.find_by_user_id_and_workday(user.id,nil) || Work.default
      if override_time
        if work_time.user_id.nil?
          w = work_time.clone
          w.user_id = user.id
          w.save
          work_time = w
        end
        work_time.end_hour = override_time.hour
        work_time.end_min = override_time.min
        work_time.save
      end
      if Time.now.saturday?
        return "Det är lördag idag!"
      elsif Time.now.sunday?
        return "Det är söndag!"
      elsif (Time.now.friday? || Hday.is_holiday(Date.today + 1)) && Time.now.hour > work_time.end_hour || (Time.now.hour == work_time.end_hour && Time.now.min >= work_time.end_min)
        return "Har du inte redan tagit helg nu så borde du göra det!"
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
      print [helg, helg.wday].inspect
      work_time = Work.find_by_user_id_and_workday(user.id, helg.yesterday.wday) || Work.find_by_user_id_and_workday(user.id,nil) || Work.default
      print work_time.inspect
      helg-=(24-work_time.end_hour).hour-work_time.end_min.minutes if helg.hour == 0 
      print helg
      helg = sem.starts_at if sem && helg > sem.starts_at
      (helg - Time.now).to_i.sec_to_string+ ' till nästa ledighet'
    end
    alias :ledig :helg

    def arbetsdag(msg)
      date = Date.today
      if !msg.message.empty?
        date = Date.parse(msg.message)
      end
      weekdays = %w(mörv måndag tisdag onsdag torsdag fredag lördag söndag)
      workday = !Hday.is_holiday(date)
      if !workday
        reasons = Hday.free_dates(date.year)
        reason = weekdays[date.cwday]
        if(reasons.has_key?(date))
          reason = Hday.to_string(reasons[date])
        end
        return 'Nej, ' + reason
      end
      'Ja, ' + weekdays[date.cwday]
    end
#  end

end
