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
          sentence = {
            :text                => s.text.content,
            :words               => syntax(s.text.content),
            :words_count         => syllables.size,
            :syllables           => syllables(s.text.content),
            :syllables_count     => syllables.flatten.size,
            :sentiment_score     => s.sentiment.score,
            :sentiment_magnitude => s.sentiment.magnitude
          }
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
        sentence = {
          :text                => s.text.content,
          :words               => syntax(s.text.content),
          :words_count         => syllables.size,
          :syllables           => syllables(s.text.content),
          :syllables_count     => syllables.flatten.size,
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
