require 'tilt/haml'
require 'sinatra'
require_relative 'articles'

get '/' do
  a = get_feed()
  #h = get_sentiments(a.map { |n| n.title })
  #p = get_places(a.map { |n| n.title })

  b = get_feed_filter(LOCAL_FEED_URLS, "environmental")
  r = rank((a + b).map { |n| Article.new(n.title, n.description, n.link) })
  haml :index, :locals => {:items => r}
end

get '/analyze' do
  link = params[:link]
  wikipedia = get_keywords(link).select{ |l| does_wikipedia_page_exist(l) }
  wikipedia = wikipedia.map{ |w| {text: w, link: "https://en.wikipedia.org/wiki/#{w}"} }
  haml :analysis, :locals => {:link => link, :wikipedia => wikipedia}
end

get '/rectleaf.png' do
  send_file File.join(settings.public_folder, 'rectleaf.png')
end

def does_wikipedia_page_exist(page)
  wikipedia_link = URI.encode("https://en.wikipedia.org/wiki/#{page}")
  res = Net::HTTP.get_response(URI(wikipedia_link))
  return res.code == '200'
end
