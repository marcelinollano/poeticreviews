# Models

DB = Sequel.connect("sqlite://db/db.sqlite3")

class Thing < Sequel::Model
  one_to_many :reviews
  plugin(:timestamps, :update_on_create => true)
  plugin(:validation_helpers)

  def validate
    super
    validates_presence([:name, :url])
    validates_unique([:name, :url])
  end

  def self.save(params)
    thing  = find_or_create(:url => params[:url]) {|thing| thing.set(params)}
    thing.update(params)
    thing
  end
end

class Review < Sequel::Model
  many_to_one :thing
  one_to_many :sentences
  plugin(:timestamps, :update_on_create => true)
  plugin(:validation_helpers)

  def validate
    super
    validates_presence([:thing_id, :text, :author])
    validates_unique(:text)
  end

  def before_create
    sentiment                = Extract.sentiment(text)
    self.text                = Translate.to_spanish(text)
    self.sentiment_score     = sentiment[:score]
    self.sentiment_magnitude = sentiment[:magnitude]
    self.published_at        = published_at ? Sequel.string_to_datetime(published_at.to_s) : nil
    super
  end

  def self.save(params)
    review = find_or_create(:text => params[:text]) {|review| review.set(params)}
    review.update(params)
    review
  end

  def after_create
    sentences = Extract.all(text)
    sentences.each do |sentence|
      params = {
        :review_id           => id,
        :text                => sentence[:text],
        :syllables           => sentence[:syllables].to_s,
        :syllables_count     => sentence[:syllables_count],
        :words               => sentence[:words].to_s,
        :words_count         => sentence[:words_count],
        :sentiment_score     => sentence[:sentiment_score],
        :sentiment_magnitude => sentence[:sentiment_magnitude]
      }
      Sentence.save(params)
    end
    super
  end
end

class Sentence < Sequel::Model
  many_to_one :review
  plugin(:timestamps, :update_on_create => true)
  plugin(:validation_helpers)

  def validate
    super
    validates_presence([:review_id, :text])
    validates_unique(:text)
  end

  def self.save(params)
    sentence = find_or_create(:text => params[:text]) {|s| s.set(params)}
    sentence.update(params)
    sentence
  end
end
