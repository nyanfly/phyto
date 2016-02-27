require 'sinatra'
require_relative 'articles'


get '/' do
  a = get_feed()
  #h = get_sentiments(a.map { |n| n.title })
  #p = get_places(a.map { |n| n.title })
  r = rank(a.map { |n| n.title })
  haml :index, :locals => {:items => r}
end

get '/text_analysis' do
  a = get_feed()
  #h = get_sentiments(a.map { |n| n.title })
  #p = get_places(a.map { |n| n.title })
  r = rank(a.map { |n| n.title })
  puts r
  "hi"
end

get '/hi' do
  "Hello world!"
end
