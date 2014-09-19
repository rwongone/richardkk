require 'sinatra'
require 'data_mapper'
require './sentinence'

get "/" do
	erb :index
end

get "/projects" do
	erb :projects
end

get "/projects/sentinence/:sourceFile" do
	s = Sentinence.new
	s.process(params[:sourceFile])

	redirect to ("/projects/sentinence")
end

get "/projects/sentinence" do
	s = Sentinence.new
	@sentence = s.buildSentence

	erb :sentinences
end