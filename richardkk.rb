require 'sinatra'
require 'sinatra/sequel'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class BlogPost
	include DataMapper::Resource
	property :id,			Serial
	property :title,		String, :required => true
	property :date_time,	DateTime, :required => true
	property :content,		String, :required => true
end

DataMapper.finalize
DataMapper.auto_upgrade!

configure do
	DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://database.db')
end

configure :production do
	require 'newrelic_rpm'
end

get "/" do
	@blog_posts = BlogPost.all
	puts params
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