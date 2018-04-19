# Translate

# require "google/cloud/translate"
#
# class Translate
#   @client = Google::Cloud::Translate.new(project_id: ENV['GOOGLE_PROJECT_ID'])
#
#   def self.detect(text)
#     response = @client.detect(text)
#     response.language
#   end
#
#   def self.to_english(text)
#     if self.detect(text) == 'es'
#       text = @client.translate(text, to: 'en')
#       text = CGI.unescapeHTML(text)
#     end
#     text
#   end
#
#   def self.to_spanish(text)
#     if self.detect(text) == 'en'
#       text = @client.translate(text, to: 'es')
#       text = CGI.unescapeHTML(text)
#     end
#     text
#   end
# end
