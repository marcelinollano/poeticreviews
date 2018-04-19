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
    params = {:name =>  params[:name], :url => params[:url]}
    thing  = find_or_create(:url => params[:url]) {|thing| thing.set(params)}
    thing.update(params)
    thing
  end
end

class Review < Sequel::Model
  many_to_one :thing
  one_to_many :phrases
  plugin(:timestamps, :update_on_create => true)
  plugin(:validation_helpers)

  def validate
    super
    validates_presence([:thing_id, :text, :author])
    validates_unique(:text)
  end

  def self.save(params)
    params = {:thing_id =>  params[:thing_id], :text => params[:text], :author => params[:author]}
    review = find_or_create(:text => params[:text]) {|review| review.set(params)}
    review.update(params)
    review
  end

  def before_create
    self.english           = nil
    self.emotion_score     = nil
    self.emotion_magnitude = nil
    super
  end
end

class Phrase < Sequel::Model
  many_to_one :review
  plugin(:timestamps, :update_on_create => true)
  plugin(:validation_helpers)

  def validate
    super
    validates_presence([:review_id, :text])
    validates_unique(:text)
  end

  def self.save(params)
    params  = {:review_id =>  params[:review_id], :text => params[:text]}
    phrases = self.find_or_create(:text => params[:text]) {|phrase| phrase.set(params)}
    phrases.update(params)
    phrases
  end

  def before_create
    self.english           = nil
    self.syllabes          = nil
    self.emotion_score     = nil
    self.emotion_magnitude = nil
    self.tokens            = nil
    super
  end
end
