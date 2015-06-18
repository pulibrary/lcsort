# encoding: utf-8

class Lcsort

  TOPSPACE = ' '
  BOTTOMSPACE = '~'
  TOPDIGIT = '0'
  BOTTOMDIGIT = '9'

  LC= /^\s*
      (?:VIDEO-D)? # for video stuff
      (?:DVD-ROM)? # DVDs, obviously
      (?:CD-ROM)?  # CDs
      (?:TAPE-C)?  # Tapes
      \s*
      ([A-Z]{1,3})  # alpha
      \s*
      (?:         # optional numbers with optional decimal point
        (\d+)     # num
        (?:\s*?\.\s*?(\d+))?
      )?
      \s*
      (?:               # optional cutter
        \.? \s*
        ([A-Z])      # cutter letter  c1alpha
        \s*
        (\d+ | \Z)        # cutter numbers  c1num
      )?
      \s*
      (?:               # optional cutter
        \.? \s*
        ([A-Z])      # cutter letter  c2alpha
        \s*
        (\d+ | \Z)        # cutter numbers  c2num
      )?
      \s*
      (?:               # optional cutter
        \.? \s*
        ([A-Z])      # cutter letter  c3alpha
        \s*
        (\d+ | \Z)        # cutter numbers  c3num
      )?
      (\s+.+?)?        # everthing else extra
      \s*$/x


  # lc_nospace = lc= /\s*(?:VIDEO-D)?(?:DVD-ROM)?(?:CD-ROM)?(?:TAPE-C)?\s*([A-Z]{1,3})\s*(?:(\d+)(?:\s*?\.\s*?(\d+))?)?\s*(?:\.?\s*([A-Z])\s*(\d+|\Z))?\s*(?:\.?\s*([A-Z])\s*(\d+|\Z))?\s*(?:\.?\s*([A-Z])\s*(\d+|\Z))?(\s+.+?)?\s*$/
  #puts lc.match("HE 8700.7 p6 t44 1983")

  attr_accessor :alpha_width, :class_whole_width, :class_dec_width, :cutter_width

  def initialize()
    self.alpha_width       = 3
    self.class_whole_width = 4
    self.class_dec_width   = 6
    self.cutter_width      = 4
  end

  def self.normalize(*args)
    Lcsort.new.normalize(*args)
  end


  def filler(slot, digit)
    value = slot - digit.to_s.length
    value = 0 if value < 0
    value.to_i
  end

  def normalize(cn, opts = {})
    callnum = cn.upcase
    
    match = LC.match(callnum)
    unless match
      return nil
    end

    alpha, num, dec, c1alpha, c1num, c2alpha, c2num, c3alpha, c3num, extra = match.captures
    origs = match.captures
    
    if dec.to_s.length > 6
      return nil
    end

    if !alpha.nil? && !(!num.nil? || !dec.nil? || !c1alpha.nil? || !c1num.nil? || !c2alpha.nil? || !c2num.nil? || !c3alpha.nil? || !c3num.nil?)
      if !extra.nil?
        return nil
      end
      if opts[:bottomout]
        return alpha + BOTTOMSPACE * (alpha_width - alpha.length)
      end
      return alpha
    end
    enorm = extra.to_s.gsub(/[^A-Z0-9]/, '')
    num = '%04d' % num.to_s.to_i

    c1a = c1alpha.nil? ? TOPSPACE : c1alpha
    c2a = c2alpha.nil? ? TOPSPACE : c2alpha
    c3a = c3alpha.nil? ? TOPSPACE : c3alpha


    topnorm = [
      alpha.to_s + TOPSPACE * filler(alpha_width, alpha),
      num.to_s + TOPDIGIT * filler(class_whole_width, num),
      dec.to_s + TOPDIGIT * filler(class_dec_width, dec),
      c1a,
      c1num.to_s + TOPDIGIT * filler(cutter_width - 1, c1num),
      c2a,
      c2num.to_s + TOPDIGIT * filler(cutter_width - 1, c2num),
      c3a,
      c3num.to_s + TOPDIGIT * filler(cutter_width - 1, c3num),
      ' ' + enorm,
    ]

    if !extra.nil?
      return topnorm.join
    end

    c1al = c1alpha.nil? ? BOTTOMSPACE : c1alpha
    c2al = c2alpha.nil? ? BOTTOMSPACE : c2alpha
    c3al = c3alpha.nil? ? BOTTOMSPACE : c3alpha 

    bottomnorm = [
      alpha.to_s + BOTTOMSPACE * filler(alpha_width, alpha),
      num.to_s + BOTTOMDIGIT * filler(class_whole_width, num),
      dec.to_s + BOTTOMDIGIT * filler(class_dec_width, dec),
      c1al,
      c1num.to_s + BOTTOMDIGIT * filler(cutter_width - 1, c1num),
      c2al,
      c2num.to_s + BOTTOMDIGIT * filler(cutter_width - 1, c2num),
      c3al,
      c3num.to_s + BOTTOMDIGIT * filler(cutter_width - 1, c3num)
    ]




    (1..9).to_a.reverse_each do |i|
      lasttop = topnorm.pop
      if origs[i]
        if opts[:bottomout]
          lasttop = bottomnorm[i..8].join
        end
        return topnorm.join + lasttop
      end
    end

  end

  # puts normalize(ARGV[0], ARGV[1])
end
