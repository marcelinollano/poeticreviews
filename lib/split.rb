# Split

require "google/cloud/language"

class Split
  @client = Google::Cloud::Language.new

  def self.to_sentences(text)
    response = @client.analyze_syntax(:content => text, :type => :PLAIN_TEXT)
    response = Split.to_sentences("This is the end of the world. And you know it.")
    # response.sentences.each do |sentence|
    #   p sentence.text.content
    # end



  end
end

# sentences = response.sentences
# tokens    = response.tokens
#
# puts "Sentences: #{sentences.count}"
# puts "Tokens: #{tokens.count}"
#
# tokens.each do |token|
#   puts "#{token.part_of_speech.tag} #{token.text.content}"
# end
