# Process

require "google/cloud/language"

class Extract
  @client = Google::Cloud::Language.new

  def self.sentiment(text)
    response = @client.analyze_sentiment(:content => text, :type => :PLAIN_TEXT)
    sentiment = {
      :score => response.document_sentiment.score,
      :magnitude => response.document_sentiment.magnitude
    }
    sentiment
  end

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
