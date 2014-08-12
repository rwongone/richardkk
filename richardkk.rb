require 'sinatra'

get "/" do
	erb :index
end

get "/blog" do
	erb :blog
end

get "/music" do
	erb :music
end

get "/reading_list" do
	erb :reading_list
end