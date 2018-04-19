# Process

require "google/cloud/language"

class Extract
  @client = Google::Cloud::Language.new

  # def self.emotion(text)
  #   response = @client.analyze_syntax(:content => text, :type => :PLAIN_TEXT)
  #   emotion = {
  #     :score => response.sentiment.score,
  #     :magnitude => response.sentiment.magnitude
  #   }
  #   emotion
  # end

  def self.syntax(text)
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
  end

  def self.sentences(text)
    document = {:content => text, :type => :PLAIN_TEXT}
    features = {:extract_document_sentiment => true, :extract_syntax => true}
    response = @client.annotate_text(document, features)

    sentences = Array.new
    response.sentences.each do |s|
      sentence = {
        :text => s.text.content,
        :score => s.sentiment.score,
        :magnitude => s.sentiment.magnitude,
        :tokens => syntax(s.text.content)
      }
      sentences << sentence
    end
    sentences
  end
end
