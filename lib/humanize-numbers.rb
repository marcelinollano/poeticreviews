# Humanize numbers <https://github.com/gedera/humanize_numbers>
class Humanize
  def number(number)

    words = []

    if number.to_i == 0
      words << self.zero_string
    else
      decimal = number.to_s.split(".")[1].nil? ? 0 : number.to_s.split(".")[1].to_i
      number = number.to_s.split(".")[0]

      number = number.rjust(33,'0').reverse
      groups = number.scan(/.../)

      words << number_to_words(groups[0].reverse)

      (1..10).each do |number|
        if groups[number].to_i > 0
          case number
          when 1,3,5,7,9
            words << "thousand" if ENV['LOCALE'] == 'en'
            words << "mil" if ENV['LOCALE'] == 'es'
            words << "mil" if ENV['LOCALE'] == 'pt'
          else
            words << (groups[number].reverse.to_i > 1 ? "#{self.quantities[number]}" : "#{self.quantities[number]}") if ENV['LOCALE'] == 'en'
            words << (groups[number].reverse.to_i > 1 ? "#{self.quantities[number]}" : "#{self.quantities[number]}") if ENV['LOCALE'] == 'pt'
            words << (groups[number].reverse.to_i > 1 ? "#{self.quantities[number]}ones" : "#{self.quantities[number]}ón") if ENV['LOCALE'] == 'es'
          end
          words << number_to_words(groups[number].reverse)
        end
      end
    end
    return "#{words.reverse.join(' ')}"
  end

  protected

  def conector
    case ENV['LOCALE']
    when 'en'
      "with"
    when 'es'
      "con"
    when 'pt'
      "com"
    end
  end

  def and_string
    return "y" if ENV['LOCALE'] == 'es'
    return "e" if ENV['LOCALE'] == 'pt'
  end

  def zero_string
    case ENV['LOCALE']
    when 'en'
      "zero"
    when 'es'
      "cero"
    end
  end

  def units
    # 1, 2, 3, 4, 5, 6, 7, 8, 9, 10
    case ENV['LOCALE']
    when 'en'
      %w[ ~ one two three four five six seven eight nine ]
    when 'es'
      %w[ ~ uno dos tres cuatro cinco seis siete ocho nueve ]
    when 'pt'
      %w[ ~ um dois três quatro cinco seis sete oito nove ]
    end
  end

  def tens
    # 10, 20, 30, 40, 50, 60, 70, 80, 90
    case ENV['LOCALE']
    when 'en'
      %w[ ~ ten twenty thirty forty fifty sixty seventy eighty ninety ]
    when 'es'
      %w[ ~ diez veinte treinta cuarenta cincuenta sesenta setenta ochenta noventa ]
    when 'pt'
      %w[ ~ dez veinte trinta quarenta cinquenta sessenta setenta oitenta noventa ]
    end
  end

  def hundreds
    # 100, 200, 300, 400 , 500, 600, 700, 800, 900
    case ENV['LOCALE']
    when 'en'
      [ nil, 'one hundred', 'two hundred', 'three hundred', 'four hundred', 'five hundred', 'six hundred', 'seven hundred', 'eight hundred', 'nine hundred' ]
    when 'es'
      %w[ cien ciento doscientos trescientos cuatrocientos quinientos seiscientos setecientos ochocientos novecientos ]
    when 'pt'
      %w[ ~ cem duzentos trezentos quatrocentos quinhentos seiscentos setecentos oitocentos novecentos ]
    end
  end

  def teens
    # 10, 11, 12, 13, 14, 15, 16, 17, 18, 19
    case ENV['LOCALE']
    when 'en'
      %w[ ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen ]
    when 'es'
      %w[ diez once doce trece catorce quince dieciseis diecisiete dieciocho diecinueve ]
    when 'pt'
      %W[ dez onze doze treze catorze quinze dezesseis dezessete dezoito dezenove ]
    end
  end

  def quantities
    case ENV['LOCALE']
    when 'en'
      %w[ ~ ~ mill ~ bill ~ trill ~ cuatrill ~ quintill ~ ]
    when 'es'
      %w[ ~ ~ milli ~ billi ~ trilli ~ ]
    when 'pt'
      %[ ~ ~ milhão ~ bilhão ~ trilhão ~  mil bilhões ~ quintilhões ]
    end
  end

  def number_to_words(number)
    hundreds = number[0,1].to_i
    tens = number[1,1].to_i
    units = number[2,1].to_i

    text = []

    if hundreds > 0
      if hundreds == 1 && (tens + units == 0)
        text << self.hundreds[0]
      else
        text << self.hundreds[hundreds]
      end
    end

    if tens > 0
      case tens
      when 1
        text << (units == 0 ? self.tens[tens] : self.teens[units])
      when 2
        text << (units == 0 ? self.tens[tens] : "veinti#{self.units[units]}") if ENV['LOCALE'] == 'es'
        text << self.tens[tens] if ENV['LOCALE'] == 'en'
        text <<  "#{self.and_string} #{self.tens[tens]}" if ENV['LOCALE'] == 'pt'
      else
        text << self.and_string if (ENV['LOCALE'] == 'pt' and hundreds > 0)
        text << self.tens[tens]
      end
    end

    if units > 0
      if tens == 0
        text << self.units[units]
      elsif tens > 2
        text << "#{self.and_string} #{self.units[units]}" if ENV['LOCALE'] == 'es'
        text << "#{self.and_string} #{self.units[units]}" if ENV['LOCALE'] == 'pt'
        text << self.units[units] if ENV['LOCALE'] == 'en'
      else
        text << "#{self.and_string} #{self.units[units]}" if ENV['LOCALE'] == 'pt'
        text << self.units[units] if ENV['LOCALE'] == 'en'
      end
    end
    return text.join(' ')
  end
end
