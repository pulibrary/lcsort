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


  attr_accessor :alpha_width, :class_whole_width
  attr_accessor :cutter_prefix_separator, :cutter_intermediate_separator

  def initialize()
    self.alpha_width       = 3
    self.class_whole_width = 4

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

    # We can't handle a class number wider than the space we have
    if num && num.length > self.class_whole_width
      return nil
    end

    normal_str = ""

    # Right fill alpha class with separators, to ensure sort, we
    # always have alpha.
    normal_str << right_fill( alpha, alpha_width,        LOW_CHAR)

    # Left-fill whole number with preceding 0's to ensure sort,
    # Only needed if present, sort will work right regardless. 
    if num
      normal_str << "%0#{class_whole_width}d" % num.to_s.to_i
    end

    # decimal class number needs no fill, add it if we have it.
    # relies on fixed width whole number to sort properly.
    normal_str << dec  if dec

    # add cutters only if they are present
    normal_str << normalize_cutter(c1alpha, c1num) if c1alpha
    normal_str << normalize_cutter(c2alpha, c2num) if c2alpha
    normal_str << normalize_cutter(c3alpha, c3num) if c3alpha

    # If we don't have 'extra' and bottomout was requested,
    # return with high space to provide range limit going
    # AFTER what's trucated.
    if opts[:bottomout] == true && extra.nil?
      return normal_str << HIGH_CHAR
    else
      # require an alpha and a num to be a good call number,
      # although above in bottomout we'll allow just alpha.
      unless alpha && num
        return nil
      end

      # Add normalized extra if we've got it
      if extra
        normal_str << (LOW_CHAR + LOW_CHAR + extra.to_s.gsub(/[^A-Z0-9]/, ''))
      end
      return normal_str
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
