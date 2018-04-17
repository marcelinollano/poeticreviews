# # Imports the Google Cloud client library
# require "google/cloud/language"
#
# # Instantiates a client
# language = Google::Cloud::Language.new
#
# # The text to analyze
# text = "Ni de coña"
#
# # Detects the sentiment of the text
# response = language.analyze_sentiment content: text, type: :PLAIN_TEXT
#
# # Get document sentiment from response
# sentiment = response.document_sentiment
#
# puts "Text: #{text}"
# puts "Score: #{sentiment.score}, #{sentiment.magnitude}"


text_content = "Pero que cosas me dices"

require "google/cloud/language"

language = Google::Cloud::Language.new
response = language.analyze_syntax content: text_content, type: :PLAIN_TEXT

sentences = response.sentences
tokens    = response.tokens

puts "Sentences: #{sentences.count}"
puts "Tokens: #{tokens.count}"

tokens.each do |token|
  puts "#{token.part_of_speech.tag} #{token.text.content}"
end
