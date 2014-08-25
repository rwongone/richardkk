require 'sinatra'
require 'data_mapper'

configure :development do
    DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

configure :production do
	require 'newrelic_rpm'
	DataMapper.setup(:default, ENV['HEROKU_POSTGRESQL_AQUA_URL'])
end

class BlogPost
	include DataMapper::Resource
	property :id,			Serial
	property :title,		String, :required => true
	property :date_time,	DateTime, :required => true
	property :content,		String, :required => true
end

class WikiResult
	include DataMapper::Resource
	property :id,			Serial
	property :title,		String, :required => true
	property :content,		String, :required => true
end

DataMapper.finalize
DataMapper.auto_upgrade!

def simple_article(title, content)
	return markup("article", markup("h3", title) + markup("p", content))
end

def article(title, timestamp, content)
	return markup("article", markup("h3", title) + markup("h4", timestamp) + markup("p", content))
end

def markup(tag, content)
	return "<"+tag+">"+content+"</"+tag+">"
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

get "/wiki_phil/new" do
	erb :new_wiki_phil
end

get "/wiki_phil" do
	@results = WikiResult.all
	erb :wiki_phil
end

post "/wiki_phil" do
	@start_page = params[:start_page]
	@ends_w_phil = params[:ends_w_phil]
	redirect to ("wiki_phil")
end