# Process

require "google/cloud/language"

class Extract
  @client = Google::Cloud::Language.new

  # Multilingual
  def self.syntax(text)
    begin
      response = @client.analyze_syntax(:content => text, :type => :PLAIN_TEXT)
      tokens = Array.new
      response.tokens.each do |t|
        token = {
          :text => t.text.content,
          :tag  => t.part_of_speech.tag
        }
        tokens << token
      end
      tokens
    rescue
      nil
    end
  end

  # Multilingual
  def self.sentiment(text)
    begin
      response = @client.analyze_sentiment(:content => text, :type => :PLAIN_TEXT)
      sentiment = {
        :score => response.document_sentiment.score,
        :magnitude => response.document_sentiment.magnitude
      }
    rescue
      sentiment = {
        :score => 0,
        :magnitude => 0
      }
    end
    sentiment
  end

  # Multilingual
  def self.split!(text)
    text = text.gsub(/[.,;?!…)]/, '\0|')
    text = text.split('|')
    text
  end

  # Spanish
  def self.syllables_from_word(word)
    client = Syllables.new(word)
    client.process
    syllables = Array.new
    client.syllables.size.times do |position|
      starting = client.syllables[position]
      ending   = client.syllables[position+1].nil? ? -1 : client.syllables[position+1] - 1
      stressed = (position + 1 == client.stressed) ? true : false
      syllable = {:text => word.slice(starting..ending), :stressed => stressed}
      syllables <<  syllable
    end
    syllables
  end

  # Spanish
  def self.syllables(text)
    words = syntax(text)
    syllables = Array.new
    words.each do |word|
      unless word[:tag] == :PUNCT # Not sure about :NUM
        syllables << syllables_from_word(word[:text])
      end
    end
    syllables
  end

  def self.find_vowels(str)
    vowels = str.scan(/[aeouiáéíóú]/).join('')
    vowels
  end

  def self.replace_vowels(str)
    str.gsub!('á', 'a')
    str.gsub!('é', 'e')
    str.gsub!('í', 'i')
    str.gsub!('ó', 'o')
    str.gsub!('ú', 'u')
    str
  end

  # Spanish
  def self.assonance(syllables)
    vowels = String.new
    vowels << find_vowels(syllables.flatten[-2][:text])
    vowels << "|"
    vowels << find_vowels(syllables.flatten[-1][:text])
    vowels = replace_vowels(vowels)
  end

  # Spanish
  def self.consonance(syllables)
    vowels = String.new
    last        = syllables.flatten[-1]
    before_last = syllables.flatten[-2]

    if last[:stressed] == true
      vowel = find_vowels(last[:text])[-1]
      split = last[:text].split(vowel)
      if split.size > 1
        vowels << vowel
        vowels << last[:text].split(vowel)[-1]
      else
        vowels << vowel
      end
    else
      vowel = find_vowels(before_last[:text])[-1]
      split = before_last[:text].split(vowel)
      if split.size > 1
        vowels << vowel
        vowels << before_last[:text].split(vowel)[-1]
      else
        vowels << vowel
      end
      vowels << "|"
      vowels << syllables.flatten[-1][:text]
    end
    vowels = replace_vowels(vowels)
  end

  # Multilingual
  def self.first_word(words)
    words = words.to_a
    if words[0][:tag] == :PUNCT
      word = words[1][:text]
    else
      word = words[0][:text]
    end
    word.capitalize
  end

  # Multilingual
  def self.last_word(words)
    words = words.to_a
    if words[-1][:tag] == :PUNCT
      word = words[-2][:text]
    else
      word = words[-1][:text]
    end
    word
  end

  # Spanish
  def self.all(text)
    begin
      document = {:content => text, :type => :PLAIN_TEXT}
      features = {:extract_document_sentiment => true, :extract_syntax => true}
      response = @client.annotate_text(document, features)
      sentences = Array.new
      response.sentences.each do |s|
        unless s.nil?
          syllables = syllables(s.text.content)
          words     = syntax(s.text.content)
          sentence = {
            :text                => s.text.content,
            :words               => words,
            :words_first         => first_word(words),
            :words_last          => last_word(words),
            :words_count         => syllables.size,
            :syllables           => syllables,
            :syllables_count     => syllables.flatten.size,
            :rhyme_assonance     => assonance(syllables),
            :rhyme_consonance    => consonance(syllables),
            :sentiment_score     => s.sentiment.score,
            :sentiment_magnitude => s.sentiment.magnitude
          }
          # puts first_word(words)
          sentences << sentence
        end
      end
      sentences
    rescue
      nil
    end
  end

  # Spanish
  def self.first(text)
    begin
      document = {:content => text, :type => :PLAIN_TEXT}
      features = {:extract_document_sentiment => true, :extract_syntax => true}
      response = @client.annotate_text(document, features)
      s = response.sentences.first
      unless s.nil?
        syllables = syllables(s.text.content)
        words     = syntax(s.text.content)
        sentence = {
          :text                => s.text.content,
          :words               => words,
          :words_first         => first_word(words),
          :words_last          => last_word(words),
          :words_count         => syllables.size,
          :syllables           => syllables,
          :syllables_count     => syllables.flatten.size,
          :rhyme_assonance     => assonance(syllables),
          :rhyme_consonance    => consonance(syllables),
          :sentiment_score     => s.sentiment.score,
          :sentiment_magnitude => s.sentiment.magnitude
        }
        sentence
      end
    rescue
      nil
    end
  end
end
