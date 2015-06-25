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
        # cutter numeric portion is optional entirely IF at end of string, to
        # support bottomout on partial cutters
        # optional cutter letter suffixes are also supported
        # ie .A12ab -- which requires lookahead to make sure not absorbing subsequent
        # cutter, doh. 
        \s*
        (\d+                              # cutter numbers c1num
          (?: [a-zA-Z]{0,2}(?=[ \.]|\Z))? # ...with optional 1-2 letter suffix
        | \Z)  
      )?
      \s*
      (?:               # optional cutter
        \.? \s*
        ([A-Z])      # cutter letter  c2alpha
        \s*
        (\d+                              # cutter numbers c1num
          (?: [a-zA-Z]{0,2}(?=[ \.]|\Z))? # ...with optional 1-2 letter suffix
        | \Z)
      )?
      \s*
      (?:               # optional cutter
        \.? \s*
        ([A-Z])      # cutter letter  c3alpha
        \s*
        (\d+                              # cutter numbers c1num
          (?: [a-zA-Z]{0,2}(?=[ \.]|\Z))? # ...with optional 1-2 letter suffix
        | \Z) 
      )?
      (\s+.+?)?        # everthing else extra
      \s*$/x


  attr_accessor :alpha_width, :class_whole_width, :class_dec_width
  attr_accessor :cutter_prefix_separator, :cutter_intermediate_separator

  def initialize()
    self.alpha_width       = 3
    self.class_whole_width = 4
    self.class_dec_width   = 6

    # cutter prefix separator must be lower ascii value than digit 0,
    # but higher than cutter_intermediate_separator
    self.cutter_prefix_separator       = '.'
    # cutter intermediate separator separates cutter letter suffixes
    # ei as in the 'ab' A234ab. It must be higher ascii value than
    # cutter_prefix_separator
    self.cutter_intermediate_separator = '-'
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


    normalized_components = [
      # Right fill alpha class with separators, to ensure sort
      right_fill( alpha, alpha_width,        LOW_CHAR),
      # Left-fill whole number with preceding 0's to ensure sort
      "%0#{class_whole_width}d" % num.to_s.to_i,
      # right fill decimal class with 0's, not actually neccesary
      # for sort in current algorithm, do we keep doing it?
      right_fill( dec,   class_dec_width,    LOW_DIGIT)
    ]
    # add cutters only if they are present
    normalized_components << normalize_cutter(c1alpha, c1num) if c1alpha
    normalized_components << normalize_cutter(c2alpha, c2num) if c2alpha
    normalized_components << normalize_cutter(c3alpha, c3num) if c3alpha

    # leave extra as it's own thing for now
    # Need DOUBLE LOW_CHAR to make sure separate from cutter, 
    # so "AB 101 [extra]" always sorts before "AB 101 [cutters]"      
    normalized_extra = (extra ? (LOW_CHAR + LOW_CHAR + extra.to_s.gsub(/[^A-Z0-9]/, '')) : '')



    if opts[:bottomout] != true || !extra.nil?   
      # Standard normalization if bottomout wasn't requested, or
      # we have 'extra' and can't do it. 

      return normalized_components.join('') << normalized_extra
    else
      #bottomout top of range normalization

      value = ""

      # We always have a class letter, and add in our normalized
      # whole number. 
      value << normalized_components[0]
      value << normalized_components[1]

      # For class decimal, we use the bottomed out norm I.F.F. we
      # are the end of the call num, 
      # to support decimal truncation as in original behavior
      value << if normalized_components.length > 3
        normalized_components[2]
      else
        right_fill( dec,    class_dec_width,   HIGH_DIGIT)
      end

      # Add in all cutters as already normalized
      value << normalized_components.slice(3..-1).join('')

      # The extra shouldn't be present if we're in this branch, but we do
      # need to add a high space on end, to make sure this goes AFTER
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

  def normalize_cutter(c_alpha_prefix, c_rest)    
    return nil if c_alpha_prefix.nil?

    # Put a low separator before alpha suffix if present, to
    # ensure sort. 
    c_rest = c_rest.sub(/(.*\d)([a-zA-Z]{1,2})\Z/, "\\1#{self.cutter_intermediate_separator}\\2")

    self.cutter_prefix_separator + c_alpha_prefix + c_rest
  end
    
end
