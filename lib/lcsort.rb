# encoding: utf-8

require 'lcsort/volume_abbreviations'

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
        (?:\s*?\.\s*?(\d+))?  # dec
      )?
      \s*
      (?:         # optional doon1 -- date or other number eg 1991 , 103rd, 103d
        \.?
        (\d{1,4})
        (?:ST|ND|RD|TH|D)?
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
        (\d+                              # cutter numbers c2num
          (?: [a-zA-Z]{0,2}(?=[ \.]|\Z))? # ...with optional 1-2 letter suffix
        | \Z)
      )?
      \s*
      (?:               # optional cutter
        \.? \s*
        ([A-Z])      # cutter letter  c3alpha
        \s*
        (\d+                              # cutter numbers c3num
          (?: [a-zA-Z]{0,2}(?=[ \.]|\Z))? # ...with optional 1-2 letter suffix
        | \Z)
      )?
      (\s+.+?)?        # everthing else extra
      \s*$/x


  attr_accessor :alpha_width, :class_whole_width, :doon_width, :extra_vol_num_width
  attr_accessor :cutter_prefix_separator, :cutter_intermediate_separator
  attr_accessor :extra_num_regexp

  def initialize()
    self.alpha_width       = 3
    self.class_whole_width = 4
    self.doon_width        = 4
    self.extra_vol_num_width = 4

    # cutter prefix separator must be lower ascii value than digit 0,
    # but higher than cutter_intermediate_separator
    self.cutter_prefix_separator       = '.'
    # cutter intermediate separator separates cutter letter suffixes
    # ei as in the 'ab' A234ab. It must be higher ascii value than
    # cutter_prefix_separator
    self.cutter_intermediate_separator = '-'

    # Prefixes in 'extra' that precede whole numbers that need
    # to be padded for sort. Prefix followed by period, optional spacing,
    # and number. Two capturing groups, the prefix as matched, and the number. 
    self.extra_num_regexp = /(\b#{Regexp.union( Lcsort::VolumeAbbreviations )}\. *)(\d+)/
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

    alpha, num, dec, doon1, c1alpha, c1num, c2alpha, c2num, c3alpha, c3num, extra = match.captures

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
      normal_str << left_fill_number(num, class_whole_width)
    end

    # decimal class number needs no fill, add it if we have it.
    # relies on fixed width whole number to sort properly.
    normal_str << dec  if dec

    # Add doon1 if present, left-pad to four digits to treat as
    # whole number.
    normal_str << normalize_doon(doon1) if doon1

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
        normal_str << normalize_extra(extra)
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

  # Left-pad a whole number with zeroes to specified width
  def left_fill_number(content, width)
    content = content.to_s
    fill_spots = width - content.length
    fill_spots = 0 if fill_spots < 0

    return ('0' * fill_spots) + content 
  end

  def normalize_cutter(c_alpha_prefix, c_rest)
    return nil if c_alpha_prefix.nil?

    # Put a low separator before alpha suffix if present, to
    # ensure sort.
    c_rest = c_rest.sub(/(.*\d)([a-zA-Z]{1,2})\Z/, "\\1#{self.cutter_intermediate_separator}\\2")

    self.cutter_prefix_separator + c_alpha_prefix + c_rest
  end

  def normalize_doon(doon)
    return nil if doon.nil?

    self.cutter_prefix_separator + left_fill_number(doon, self.doon_width)
  end

  # The 'extra' component is normalized by making it all alphanumeric,
  # and adding an ultra low prefix separator. 
  def normalize_extra(extra)
    # Left-pad any volume/number type designations with zeros, so
    # they sort appropriately. 
    extra_normalized = extra.gsub(self.extra_num_regexp) do |match|
      normalized_whole_num = left_fill_number($2, self.extra_vol_num_width)
      "#{$1}#{normalized_whole_num}"
    end

    # remove all non-alphanumeric
    extra_normalized = extra_normalized.gsub(/[^A-Z0-9]/, '')

    # Add very low prefix separator
    return (LOW_CHAR + LOW_CHAR + extra_normalized)
  end

end
