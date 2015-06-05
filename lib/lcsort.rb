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


  def self.filler(slot, digit)
    value = slot - digit.to_s.length
    value = 0 if value < 0
    value.to_i
  end

  def self.normalize(cn, opts = {})
    callnum = cn.upcase.gsub(/^[^A-Z0-9]*|[^A-Z0-9]*$/, '')
    
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
        return alpha + BOTTOMSPACE * (3 - alpha.length)
      end
      return alpha
    end
    enorm = extra.to_s.gsub(/[^A-Z0-9]/, '')
    num = '%04d' % num.to_s.to_i

    c1a = c1alpha.nil? ? TOPSPACE : c1alpha
    c2a = c2alpha.nil? ? TOPSPACE : c2alpha
    c3a = c3alpha.nil? ? TOPSPACE : c3alpha


    topnorm = [
      alpha.to_s + TOPSPACE * filler(3, alpha),
      num.to_s + TOPDIGIT * filler(4, num),
      dec.to_s + TOPDIGIT * filler(6, dec),
      c1a,
      c1num.to_s + TOPDIGIT * filler(3, c1num),
      c2a,
      c2num.to_s + TOPDIGIT * filler(3, c2num),
      c3a,
      c3num.to_s + TOPDIGIT * filler(3, c3num),
      ' ' + enorm,
    ]

    if !extra.nil?
      return topnorm.join
    end

    c1al = c1alpha.nil? ? BOTTOMSPACE : c1alpha
    c2al = c2alpha.nil? ? BOTTOMSPACE : c2alpha
    c3al = c3alpha.nil? ? BOTTOMSPACE : c3alpha 

    bottomnorm = [
      alpha.to_s + BOTTOMSPACE * filler(3, alpha),
      num.to_s + BOTTOMDIGIT * filler(4, num),
      dec.to_s + BOTTOMDIGIT * filler(6, dec),
      c1al,
      c1num.to_s + BOTTOMDIGIT * filler(3, c1num),
      c2al,
      c2num.to_s + BOTTOMDIGIT * filler(3, c2num),
      c3al,
      c3num.to_s + BOTTOMDIGIT * filler(3, c3num)
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
