# Utils

require "google/cloud/translate"

class Translate
  @client = Google::Cloud::Translate.new(project_id: ENV['GOOGLE_PROJECT_ID'])

  def self.detect(text)
    language = @client.detect(text)
    language
  end

  def self.to_english(text)
    translation = @client.translate(text, to: 'en')
    translation
  end

  def self.to_spanish(text)
    translation = @client.translate(text, to: 'en')
    translation
  end
end
