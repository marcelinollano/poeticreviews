# Models definition
DB = Sequel.connect("sqlite://db/db.sqlite3")

class Thing < Sequel::Model
  one_to_many :reviews
  one_to_many :sentences
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
    self.text                = text
    self.sentiment_score     = sentiment[:score]
    self.sentiment_magnitude = sentiment[:magnitude]
    super
  end

  def self.save(params)
    review = find_or_create(:text => params[:text]) {|review| review.set(params)}
    review.update(params)
    review
  end

  def after_create
    sentences = Extract.all(text)
    unless sentences.nil?
      sentences.each do |sentence|
        params = {
          :thing_id            => thing_id,
          :review_id           => id,
          :text                => sentence[:text].capitalize,
          :words_json          => sentence[:words].to_json,
          :words_first         => sentence[:words_first],
          :words_last          => sentence[:words_last],
          :words_count         => sentence[:words_count],
          :syllables_json      => sentence[:syllables].to_json,
          :syllables_count     => sentence[:syllables_count],
          :rhyme_assonance     => sentence[:rhyme_assonance],
          :rhyme_consonance    => sentence[:rhyme_consonance],
          :sentiment_score     => sentence[:sentiment_score],
          :sentiment_magnitude => sentence[:sentiment_magnitude]
        }
        Sentence.save(params) unless params[:text].empty?
      end
    end

    # Further break sentences
    sentences = Extract.split!(text)
    unless sentences.nil?
      sentences.each do |sentence|
        sentence = Extract.first(sentence)
        unless sentence.nil?
          params = {
            :thing_id            => thing_id,
            :review_id           => id,
            :text                => sentence[:text].capitalize,
            :words_json          => sentence[:words].to_json,
            :words_first         => sentence[:words_first],
            :words_last          => sentence[:words_last],
            :words_count         => sentence[:words_count],
            :syllables_json      => sentence[:syllables].to_json,
            :syllables_count     => sentence[:syllables_count],
            :rhyme_assonance     => sentence[:rhyme_assonance],
            :rhyme_consonance    => sentence[:rhyme_consonance],
            :sentiment_score     => sentence[:sentiment_score],
            :sentiment_magnitude => sentence[:sentiment_magnitude]
          }
          Sentence.save(params) unless params[:text].empty?
        end
      end
    end
    super
  end
end

class Sentence < Sequel::Model
  many_to_one :thing
  many_to_one :review
  plugin(:timestamps, :update_on_create => true)
  plugin(:validation_helpers)

  def validate
    super
    validates_presence([:review_id, :text])
    validates_unique(:text)
  end

  def syllables
    json = JSON.parse(syllables_json)
    json
  end

  def words
    json = JSON.parse(words_json)
    json
  end

  def self.save(params)
    sentence = find_or_create(:text => params[:text]) {|s| s.set(params)}
    sentence.update(params)
    sentence
  end
end
