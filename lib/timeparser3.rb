# coding: utf-8
module TimeParser
  require 'date'
  require 'time'

  class TimeUnit
    attr_accessor :child, :reoccur, :every, :start, :slut, :possible, :value
    attr_reader :parent
    def initialize(child=nil)
      @reoccur = false
      @every = 1
      @start = 0
    end

    def attach_child(child)
      @child=child
      @child.parent=self
    end

    def parent= p
      @parent = p
    end
  end

  class Year < TimeUnit
    def weeks
      52
    end
  end

  class Month < TimeUnit
    def initialize()
      @possible = (0..12)
      super
    end

    def days
      31
    end

    def weeks
      5
    end
  end

  class Week < TimeUnit
    def initialize()
      super
    end

    def parent= p
      super
      case p.class.to_s
      when TimeParser::Year.to_s
        @possible=(0..p.weeks)
      when TimeParser::Month.to_s
        @possible=(1..p.weeks)
      else
      end
    end
  end

  class Day < TimeUnit
    def initialize()
      super
    end

    def parent= p
      super
      case p.class.to_s
      when TimeParser::Week.to_s
        @possible=(0..6)
      when TimeParser::Month.to_s
        @possible=(1..p.days)
      else
      end
    end
  end

end
