require 'tilt/haml'
require 'sinatra'
require_relative 'articles'

get '/' do
  a = get_feed()
  #h = get_sentiments(a.map { |n| n.title })
  #p = get_places(a.map { |n| n.title })
  r = rank(a.map { |n| [n.title, n.link] })
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

get '/leaf.png' do
  send_file File.join(settings.public_folder, 'leaf.png')
end

get '/rectleaf.png' do
  send_file File.join(settings.public_folder, 'rectleaf.png')
end