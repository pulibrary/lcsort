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


    topnorm = [
      right_fill( alpha, alpha_width,        TOPSPACE),
      right_fill( num,   class_whole_width,  TOPDIGIT),
      right_fill( dec,   class_dec_width,    TOPDIGIT),
      c1alpha || TOPSPACE, 
      right_fill( c1num, cutter_width - 1,   TOPDIGIT),
      c2alpha || TOPSPACE,
      right_fill( c2num, cutter_width - 1,   TOPDIGIT),
      c3alpha || TOPSPACE,
      right_fill( c3num, cutter_width - 1,   TOPDIGIT),
      ' ' + enorm,
    ]

    if !extra.nil?
      return topnorm.join
    end

    bottomnorm = [
      right_fill( alpha,  alpha_width,       BOTTOMSPACE),
      right_fill( num,    class_whole_width, BOTTOMDIGIT),
      right_fill( dec,    class_dec_width,   BOTTOMDIGIT),      
      c1alpha || BOTTOMSPACE,
      right_fill( c1num,  cutter_width - 1,  BOTTOMDIGIT),
      c2alpha || BOTTOMSPACE,
      right_fill( c2num,  cutter_width - 1,  BOTTOMDIGIT),
      c3alpha || BOTTOMSPACE,
      right_fill( c3num,  cutter_width - 1, BOTTOMDIGIT)
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

  def right_fill(content, width, padding)
    content = content.to_s
    fill_spots = width - content.length
    fill_spots = 0 if fill_spots < 0

    content.to_s + (padding * fill_spots)
  end


  # puts normalize(ARGV[0], ARGV[1])
end
