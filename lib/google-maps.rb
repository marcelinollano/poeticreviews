# Scraps GoogleMaps files
class GoogleMaps
  def self.read(file)
    file = File.open(file, "rb")
    content = Nokogiri::HTML(file.read)
    content
  end

  def self.humanize(text)
    digits = text.scan(/\d+/)
    humanize = Humanize.new
    digits.each do |digit|
      text.gsub!(digit, humanize.number(digit))
    end
    text
  end

  def self.cleanup(text)
    text = CGI.unescapeHTML(text)
    text = text.split("(Original)")[-1] if text.scan("(Original)")
    text = text.split("(Texto original)")[0] if text.scan("(Texto original)")
    text = humanize(text)
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
    text.gsub!("km", "kilómetro")
    text.strip!
    text
  end

  def self.scrap(html)
    content      = read(html)
    nodes        = content.css('.section-review-content')
    reviews = Array.new
    nodes.each do |node|
      text         = node.css('.section-review-text').text
      unless text.empty?
        text         = cleanup(text)
        author       = node.css('.section-review-title span').text
        review = {
          :text         => text,
          :author       => author
        }
        reviews << review
      end
    end
    reviews
  end
end
