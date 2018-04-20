# Scrap

class GoogleMaps
  def self.read(file)
    file = File.open(file, "rb")
    content = Nokogiri::HTML(file.read)
    content
  end

  def self.cleanup(text)
    text = CGI.unescapeHTML(text)
    text = text.split("(Original)")[-1] if text.scan("(Original)")
    text.gsub!(/[\n]{1,}/, " ")
    text.gsub!("/[ ]{2,}/", " ")
    text.gsub!(/[.]{2,}/, "…")
    text.gsub!("(Traducido por Google)", "")
    text.gsub!("(Translated by Google)", "")
    text.gsub!(" …", "")
    text.gsub!(" .", ".")
    text.gsub!(" ,", ",")
    text.gsub!("!.", "!")
    text.gsub!(" !", "!")
    text.gsub!("?.", "?")
    text.gsub!(" ?", "?")
    text.strip!
    text
  end

  def self.scrap(html)
    content      = read(html)
    nodes        = content.css('.section-review-content')
    reviews = Array.new
    nodes.each do |node|
      text = node.css('.section-review-text').text
      unless text.empty?
        text         = cleanup(text)
        author       = node.css('.section-review-title span').text
        published_at = Chronic.parse(node.css('.section-review-publish-date').text)
        review = {
          :text         => text,
          :author       => author,
          :published_at => published_at
        }
        reviews << review
      end
    end
    reviews
  end
end
