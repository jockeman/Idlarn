# coding: utf-8
require 'gdbm'
class Katt
  def self.init_stack()
    GDBM.new('katt.db')
  end

  def self.katt(is)
    res = if is.length > 0 and ['katt', 'cat' ].include?is[0].downcase and is[1].downcase == 'åt'
      push_stack is.join(' ')
    elsif is.length > 0 and is[0].match(/^[0-9]+$/)
      pop_stack is[0]
    else
      pop_stack 
    end
    res
  end

  def self.katter
    gdbm = init_stack
    len = gdbm.length.to_s
    gdbm.close
    "Jag har etit #{len} katter, (k)lös i magen."
  end

  def self.push_stack(i)
    gdbm = init_stack
    gdbm[gdbm.length.to_s]=i
    gdbm.close
    'Ok'
  end

  def self.pop_stack(nr = nil)
    gdbm = init_stack
    len = gdbm.length
    nr = (rand*len).floor unless nr
    katt = gdbm[nr.to_s]
    encoding = CharDet.detect(katt).encoding
    case encoding 
    when 'TIS-620', 'EUC-KR', 'utf-8'
      latin = Iconv.new('ISO-8859-15', 'utf-8')
      katt = latin.iconv(katt)
    end
    gdbm.close
    katt
  end
end
