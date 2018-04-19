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

  def self.save(params)
    review = find_or_create(:text => params[:text]) {|review| review.set(params)}
    review.update(params)
    review
  end

  def before_create
    sentiment = Extract.sentiment(text)
    self.text                = Translate.to_spanish(text)
    self.english             = Translate.to_english(text)
    self.sentiment_score     = sentiment[:score]
    self.sentiment_magnitude = sentiment[:magnitude]
    super
  end

  def after_create
    sentences = Extract.sentences(text)
    sentences.each do |sentence|
      params = {
        :review_id           => id,
        :text                => sentence[:text],
        :english             => Translate.to_english(sentence[:text]),
        :syllables            => nil,
        :sentiment_score     => sentence[:score],
        :sentiment_magnitude => sentence[:magnitude],
        :syntax              => sentence[:tokens].to_s
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
    sentences = self.find_or_create(:text => params[:text]) {|sentence| sentence.set(params)}
    sentences.update(params)
    sentences
  end
end
