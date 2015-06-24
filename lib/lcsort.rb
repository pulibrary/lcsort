# encoding: utf-8

class Lcsort

  LOW_CHAR = ' '
  HIGH_CHAR = '~'
  LOW_DIGIT = '0'
  HIGH_DIGIT = '9'

  LC= /^
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
    
    if dec.to_s.length > self.class_dec_width
      return nil
    end

    if !alpha.nil? && !(!num.nil? || !dec.nil? || !c1alpha.nil? || !c1num.nil? || !c2alpha.nil? || !c2num.nil? || !c3alpha.nil? || !c3num.nil?)
      if !extra.nil?
        return nil
      end
      if opts[:bottomout]
        return alpha + HIGH_CHAR * (alpha_width - alpha.length)
      end
      return alpha
    end

    # Left-fill whole number with preceding 0's
    num = "%0#{class_whole_width}d" % num.to_s.to_i

    topnorm = [
      right_fill( alpha, alpha_width,        LOW_CHAR),
      num,
      right_fill( dec,   class_dec_width,    LOW_DIGIT),
      normalize_cutter(c1alpha, c1num),
      normalize_cutter(c2alpha, c2num),
      normalize_cutter(c3alpha, c3num),
      (extra ? (LOW_CHAR + extra.to_s.gsub(/[^A-Z0-9]/, '')) : nil)
    ]


    if opts[:bottomout] != true || !extra.nil?   

      # Standard normalization if bottomout wasn't requested, or
      # we have 'extra' and can't do it. 

      value = ""

      # First three components: class letter, class whole, class decimal
      # Always need to be included      
      (0..2).each do |i|
        value << topnorm[i]
      end

      # Rest need to be added only if they exist, cutters and extra
      (3..(topnorm.length - 1)).each do |i|
        value << topnorm[i] if topnorm[i]
      end
      return value
    else
      #bottomout top of range normalization

      bottomnorm = [
        right_fill( alpha,  alpha_width,       HIGH_CHAR),
        num,
        right_fill( dec,    class_dec_width,   HIGH_DIGIT),
        normalize_cutter(c1alpha, c1num, HIGH_DIGIT),
        normalize_cutter(c2alpha, c2num, HIGH_DIGIT),
        normalize_cutter(c3alpha, c3num, HIGH_DIGIT)
      ]

      value = ""
      # For class letter and whole number, we take the
      # norm if present, otherwise a bottomed out norm
      (0..1).each do |i|
        x = origs[i] ? topnorm[i] : bottomnorm[i]
        value << x
      end

      # For class decimal, we use the bottomed out norm I.F.F. we
      # are the end of the call num, 
      # to support decimal truncation as in original behavior
      value << (origs[3].nil? ? bottomnorm[2] : topnorm[2])

      # Rest need to be added in only if they exist -- and we stop before
      # the final 'extra' which we don't include in bottomout
      # Last one gets added as a bottomnorm, others as topnorm. 
      (3..(topnorm.length -  2)).each do |i|
        if topnorm[i]
          value << (topnorm[i+1].nil? ? bottomnorm[i] : topnorm[i])
        end
      end

      # Add high space on end, to make sure this goes AFTER
      # everything it truncates. 
      value << HIGH_CHAR

      return value
    end
  end

  def right_fill(content, width, padding)
    content = content.to_s
    fill_spots = width - content.length
    fill_spots = 0 if fill_spots < 0

    content.to_s + (padding * fill_spots)
  end

  def normalize_cutter(c_alpha_prefix, c_rest, fill_digit = LOW_DIGIT)
    return nil if c_alpha_prefix.nil?

    c_alpha_prefix + right_fill( c_rest, cutter_width - 1,   fill_digit)
  end
    

  # puts normalize(ARGV[0], ARGV[1])
end
