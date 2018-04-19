# Syllables <https://github.com/vic/silabas.rb>

class Syllables
  attr_accessor :word, :stressed_found, :stressed, :num_syl, :letter_accent, :positions

  def initialize(word)
    @word = word.split('')
  end

  def syllables
    positions
  end

  def process
    @stressed_found = false
    @stressed = 0
    @num_syl = 0
    @letter_accent = -1
    @positions = []

    i = 0
    while i < word.length

      positions[num_syl] = i
      self.num_syl += 1

      i = on_set(i)
      i = nucleus(i)
      i = coda(i)

      if stressed_found && stressed == 0
        self.stressed = num_syl # it marks the stressed syllable
      end

      # if the word has not written accent, the stressed syllable is determined
      # according to the stress rules
      if !stressed_found
        if num_syl < 2
          self.stressed = num_syl # monosyllables
        else # polysyllables
          end_letter = word[word.length - 1]
          previuos_letter = word[word.length - 2]

          if (!is_consonant(end_letter) || end_letter == 'y') ||
            (end_letter =~ /[ns]/ && !is_consonant(previuos_letter))
            self.stressed = num_syl - 1 # stessed penultimate syllable
          else
            self.stressed = num_syl # stressed last syllable
          end

        end

        positions
      end

    end

    positions
  end

  def on_set(pos)
    last_consonant = 'a'

    while pos < word.length && is_consonant(word[pos]) && word[pos].downcase != 'y'
      last_consonant = word[pos].downcase
      pos += 1
    end

    # (q|g) + y (example: queso, gueto)

    if pos < word.length - 1
      if word[pos].downcase == 'u'
        if last_consonant == 'q'
          pos += 1
        elsif last_consonant == 'g' && word[pos+1].downcase =~ /[eéií]/i
          pos += 1
        end
      elsif last_consonant == 'g' && word[pos] =~ /ü/i
        pos += 1
      end
    end

    return pos
  end

  def nucleus(pos)
    previous = nil

    # nothing if word has no nucleous?!
    return pos if pos >= word.length

    # jumps a letter y to the starting of nucleus. it is as consonant
    pos += 1 if word[pos].downcase == 'y'

    # find fiest vowel
    if pos < word.length
      case word[pos]
      # open-vower or closed-vowel with written accent
      when /[áàéèóò]/i
        self.letter_accent = pos
        self.stressed_found = true
        previous = 0
        pos += 1
      # open vowel
      when /[aeo]/i
        previous = 0
        pos += 1
      # closed vowel with accents break some possible diphthong
      when /[íìúùü]/i
        self.letter_accent = pos
        self.stressed_found = true
        previous = 1
        pos += 1
        return pos
      # closed vowel
      when /[iu]/i
        previous = 2
        pos += 1
      end
    end

    # if 'h' has been inserted in the nucleus then it doesnt determine diphthong neither hiatus
    aitch = false
    if pos < word.length && word[pos].downcase == 'h'
      pos += 1
      aitch = true
    end

    # second vowel
    if pos < word.length
      case word[pos]
      # open vowel with written accent
      when /[áàéèóò]/i
        self.letter_accent = pos
        self.stressed_found = true if previous != 0
        if previous == 0
          if aitch
            pos -= 1
            return pos
          end
        else
          pos += 1
        end
      # open vowel
      when /[aeo]/i
        if previous == 0
          if aitch
            pos -= 1
            return pos
          end
        else
          pos += 1
        end
      # closed vowel with written accent, cant be atripthong but would be ditphtong
      when /[íìúù]/i
        self.letter_accent = pos
        if previous != 0 # diphthong
          self.stressed_found = true
          pos += 1
        elsif aitch
          pos -= 1
        end
        return pos

      # closed vowel
      when /[iuü]/i

        if pos < word.length - 1 && !is_consonant(word[pos+1]) && word[pos-1].downcase == 'h'
          pos -= 1
          return pos
        end

        # Two equals close-vowels don't form diphthong
        if word[pos] != word[pos -1]
          pos += 1
        end

        return pos
      end
    end

    # third vowel?

    if pos < word.length && word[pos].downcase =~ /[iu]/ # closed vowel
      pos += 1
      return pos
    end

    return pos
  end

  def coda(pos)
    if pos >= word.length || !is_consonant(word[pos])
      # syllable hasnt coda
      return pos
    end

    if pos == word.length - 1 # end of word
      pos += 1
      return pos
    end

    # if there is only a consonant between vowels it belongs to the following
    # syllable
    if !is_consonant(word[pos + 1])
      return pos
    end

    c1 = word[pos].downcase
    c2 = word[pos + 1].downcase

    if pos < word.length - 2
      c3 = word[pos + 2].downcase

      if !is_consonant(c3)
        # there isnt third consonant
        # the lt ch and rr begin a syllable
        return pos if c1 == 'l'  && c2 == 'l'
        return pos if c1 == 'c'  && c2 == 'h'
        return pos if c1 == 'r'  && c2 == 'r'

        # a consonant + 'h' begins a syllable, except for groups sh and rh
        if  c1 != 's' && c1 != 'r' && c2 == 'h'
          return pos
        end

        #if the letter 'y' is preceded by ome of
        # 's', 'l', 'r', 'n', or 'c' then a new
        # syllable begins in the previous consonant
        # else it begins in the letter 'y'

        if c2 == 'y'
          if c1 =~ /[slrnc]/
            return pos
          end
          pos += 1
          return pos
        end

        # groups: gl - kl - bl - vl - pl - fl - tl
        if c1 =~ /[bvckfgpt]/ && c2 == 'l'
          return pos
        end

        # groups: groups: gr - kr - dr - tr - br - vr - pr - fr
        if c1 =~ /[bvcdkfgpt]/ && c2 == 'r'
          return pos
        end

        pos += 1
        return pos

      else # there is a third consonant

        if pos + 3 == word.length # three consonants to the end, foreign words?
          if c2 == 'y' && c1 =~ /[slrnc]/ # y as a vowel
            return pos
          end

          if c3 == 'y' # 'y' at the end as vowel with c2
            pos += 1
          else # three consonants to the end, foreign words?
            pos += 3
          end

          return pos
        end

        if c2 == 'y' # y as vowel
          if c1 =~ /[slrnc]/
            return pos
          end

          pos += 1
          return pos
        end

        # the groups pt, ct, cn, ps, mn, gn, ft, pn, cz, tn and ts
        # begin a syllable when preceded by other consonant

        if "#{c2}#{c3}" =~ /pt|ct|cn|ps|mn|gn|ft|pn|cz|tn|ts/
          pos += 1
          return pos
        end

        if c3 =~ /[rl]/ || "#{c2}#{c3}" == 'ch' || c3 == 'y'
          # the consonantal groups formed by a consonant
          # following the letter 'l' or 'r' cant be separated
          # and they always begin a syllable
          pos += 1  # following sylable begins in c2
        else
          pos += 2
        end

      end

    else
      if c2 == 'y'
        return pos
      end

      pos += 2 # the word ends with two consonants
    end

    return pos
  end


  def is_consonant(c)
    c !~ /[aeiouáéíóüàèìò]/i
  end
end
