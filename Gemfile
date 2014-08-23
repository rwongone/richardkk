source 'https://rubygems.org'

ruby '2.1.0'

gem 'sinatra'
gem 'data_mapper'
gem 'newrelic_rpm'

group :production do
    gem "pg"
    gem "dm-postgres-adapter"
end

group :development do
    gem "sqlite3"
    gem "dm-sqlite-adapter"
end