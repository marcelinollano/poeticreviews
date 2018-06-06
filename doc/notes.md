# Notes

### Sentiment analysis

| Sentiment         | Values                          |
|-------------------|---------------------------------|
| Clearly Positive*	| "score": 0.8, "magnitude": 3.0  |
| Clearly Negative*	| "score": -0.6, "magnitude": 4.0 |
| Neutral	          | "score": 0.1, "magnitude": 0.0  |
| Mixed            	| "score": 0.0, "magnitude": 4.0  |

### Query Google Maps

```ruby
# Types https://developers.google.com/places/web-service/supported_types
params = {:query => 'Hola cafe Madrid', :type => 'cafe', :key => ENV['GOOGLE_MAPS_API_KEY']}
response = Curl.get('https://maps.googleapis.com/maps/api/place/textsearch/json', params)
place_id = JSON.parse(response.body_str)['results'][0]['place_id']
params = {:placeid => place_id, :key => ENV['GOOGLE_MAPS_API_KEY']}
response = Curl.get('https://maps.googleapis.com/maps/api/place/details/json', params)
puts response.body_str
```

### Queries

```ruby
sentences = Sentence.where(:syllables_count => 20)
                    .where(Sequel.like(:rhyme_assonance, rhyme))
                    .where(:sentiment_score => 0...1)
                    .where{sentiment_magnitude > 0}
                    .order(Sequel.desc(:sentiment_score)).all
```
