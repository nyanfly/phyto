require 'aylien_text_api'
require 'indico'
require 'rss'
require 'open-uri'

RSS_FEED_URLS = ['http://www.environmentalhealthnews.org/feeds/fracking', 'http://www.dailyclimate.org/feeds/topstories']
LOCALE = ['boston', 'massachusetts']
US_STATES = ['alabama', 'alaska', 'arizona', 'arkansas', 'california', 'colorado', 'connecticut', 'delaware', 'florida', 'georgia', 'hawaii', 'idaho', 'illinois', 'indiana', 'iowa', 'kansas', 'kentucky', 'louisiana', 'maine', 'maryland', 'massachusetts', 'michigan', 'minnesota', 'mississippi', 'missouri', 'montana', 'nebraska', 'nevada', 'new hampshire', 'new jersey', 'new mexico', 'new york', 'north carolina', 'north dakota', 'ohio', 'oklahoma', 'oregon', 'pennsylvania', 'rhode island', 'south carolina', 'south dakota', 'tennessee', 'texas', 'utah', 'vermont', 'virginia', 'washington', 'west virginia', 'wisconsin', 'wyoming']

Indico.api_key = '477f2a5fef3fc6d18d005df4b57aecb8'

AylienTextApi.configure do |config|
  config.app_id  = "c23c2449"
  config.app_key = "6667b39116a915ea8eb80a514751b1a3"
end
client = AylienTextApi::Client.new

def get_feed()
  a = Array.new
  RSS_FEED_URLS.each do |url|
    open(url) do |rss|
      feed = RSS::Parser.parse(rss)
      feed.items.each do |item|
        a << item
      end
    end
  end

  puts a
  return a
end

def get_people(texts)
  list = {}
  people = Indico.people(texts)
  people.each_with_index do |person, i|
    if person.size > 0 && person[0]["confidence"] > 0.75
      list[texts[i]] = person[0]["text"]
    end
  end
  return list
end

def get_organizations(texts)
  list = {}
  organizations = Indico.organizations(texts)
  organizations.each_with_index do |organization, i|
    if organization.size > 0 && organization[0]["confidence"] > 0.75
      list[texts[i]] = organization[0]["text"]
    end
  end
  return list
end

def get_places(texts)
  list = {}
  places = Indico.places(texts)
  places.each_with_index do |place, i|
    if place.size > 0 && place[0]["confidence"] > 0.75
      list[texts[i]] = place[0]["text"]
    end
  end
  return list
end

def get_sentiments(texts)
  sentiments = Indico.sentiment_hq(texts)
  hash = Hash[ texts.zip(sentiments) ]
  return hash
end

def get_hashtags(url)
  return client.hashtags(url: url, sentences_number: 3)
end

def get_summary(url)
  return client.summarize(url: url, sentences_number: 3)
end

def rank(texts)
  places = get_places(texts)
  sentiments = get_sentiments(texts)

  ratings = {}

  texts.each_with_index do |text, i|
    rating = (0.5 - sentiments[text]).abs
    if places.has_key?(text)
      rating += 1 if LOCALE.include? places[text].downcase
      rating += 0.2 if US_STATES.include? places[text].downcase
    end
    ratings[text] = rating
  end

  return Hash[ratings.sort_by{|k, v| v}.reverse]
end
