require 'sinatra'
require 'sinatra/sequel'

configure do
	DB = Sequel.connect(ENV['DATABASE_URL'] || 'sqlite://database.db')
end

configure :production do
	require 'newrelic_rpm'
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