source 'https://rubygems.org'

ruby '2.1.0'

gem 'sinatra'
gem 'newrelic_rpm'
gem 'sinatra-sequel'
gem 'padrino'

group :production do
    gem "pg"
    gem "dm-postgres-adapter"
end

group :development, :test do
    gem "sqlite3"
    gem "dm-sqlite-adapter"
end