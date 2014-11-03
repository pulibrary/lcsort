# encoding: utf-8

class Lcsort

  TOPSPACE = ' '
  BOTTOMSPACE = '~'
  TOPDIGIT = '0'
  BOTTOMDIGIT = '9'

  LC= /\s*
      (?:VIDEO-D)? # for video stuff
      (?:DVD-ROM)? # DVDs, obviously
      (?:CD-ROM)?  # CDs
      (?:TAPE-C)?  # Tapes
      \s*
      ([A-Z]{1,3})  # alpha
      \s*
      (?:         # optional numbers with optional decimal point
        (\d+)
        (?:\s*?\.\s*?(\d+))?
      )?
      \s*
      (?:               # optional cutter
        \.? \s*
        ([A-Z])      # cutter letter
        \s*
        (\d+ | \Z)        # cutter numbers
      )?
      \s*
      (?:               # optional cutter
        \.? \s*
        ([A-Z])      # cutter letter
        \s*
        (\d+ | \Z)        # cutter numbers
      )?
      \s*
      (?:               # optional cutter
        \.? \s*
        ([A-Z])      # cutter letter
        \s*
        (\d+ | \Z)        # cutter numbers
      )?
      (\s+.+?)?        # everthing else
      \s*$/x

  # lc_nospace = lc= /\s*(?:VIDEO-D)?(?:DVD-ROM)?(?:CD-ROM)?(?:TAPE-C)?\s*([A-Z]{1,3})\s*(?:(\d+)(?:\s*?\.\s*?(\d+))?)?\s*(?:\.?\s*([A-Z])\s*(\d+|\Z))?\s*(?:\.?\s*([A-Z])\s*(\d+|\Z))?\s*(?:\.?\s*([A-Z])\s*(\d+|\Z))?(\s+.+?)?\s*$/
  #puts lc.match("HE 8700.7 p6 t44 1983")


  def self.normalize(callnum, bottomout=false)
  	if match = LC.match(callnum.upcase)
  		alpha, num, dec, c1alpha, c1num, c2alpha, c2num, c3alpha, c3num, extra = match.captures
  		origs = match.captures
  	end

  	if dec.to_s.length > 2
  		return 
  	end

  	if !alpha.nil? && !(!num.nil? || !dec.nil? || !c1alpha.nil? || !c1num.nil? || !c2alpha.nil? || !c2num.nil? || !c3alpha.nil? || !c3num.nil?)
  		if !extra.nil?
  	  	return
  	  end
  	  if bottomout
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
      alpha.to_s + TOPSPACE * (3 - alpha.to_s.length),
      num.to_s + TOPDIGIT * (4 - num.to_s.length),
      dec.to_s + TOPDIGIT * (2 - dec.to_s.length),
      c1a,
      c1num.to_s + TOPDIGIT * (3 - c1num.to_s.length),
      c2a,
      c2num.to_s + TOPDIGIT * (3 - c2num.to_s.length),
      c3a,
      c3num.to_s + TOPDIGIT * (3 - c3num.to_s.length),
      ' ' + enorm,
    ]  

  	if !extra.nil?
  		return topnorm.join
  	end

    c1al = c1alpha.nil? ? BOTTOMSPACE : c1alpha
    c2al = c2alpha.nil? ? BOTTOMSPACE : c2alpha
    c3al = c3alpha.nil? ? BOTTOMSPACE : c3alpha 

    bottomnorm = [
      alpha.to_s + BOTTOMSPACE * (3 - alpha.to_s.length),
      num.to_s + BOTTOMDIGIT * (4 - num.to_s.length),
      dec.to_s + BOTTOMDIGIT * (2 - dec.to_s.length),
  		c1al,
      c1num.to_s + BOTTOMDIGIT * (3 - c1num.to_s.length),
      c2al,
      c2num.to_s + BOTTOMDIGIT * (3 - c2num.to_s.length),
      c3al,
      c3num.to_s + BOTTOMDIGIT * (3 - c3num.to_s.length)
    ]	




    (1..9).to_a.reverse_each do |i|
    	lasttop = topnorm.pop
  		if origs[i]
  			if bottomout
  				lasttop = bottomnorm[i..8].join
  			end
  			return topnorm.join + lasttop
  		end
    end

  end

  # puts normalize(ARGV[0], ARGV[1])
end
