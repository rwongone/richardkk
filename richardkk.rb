require 'sinatra'
require 'data_mapper'

DataMapper.setup(:default, "sqlite3:database.sqlite3")

class BlogPost
	include DataMapper::Resource

	property :id, Serial
	property :author, String
	property :content, String
end

get "/" do
	erb :index
end

get "/projects" do
	erb :projects
end

get "/music" do
	erb :music
end

get "/reading" do
	erb :reading
end