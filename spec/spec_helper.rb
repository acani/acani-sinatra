require 'sinatra'
# require 'rack/test'

Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

RSpec.configure do |config|
  config.before(:each) do
    conn = Mongo::Connection.new.drop_database("acani-test")
  end

  # config.after(:each) do
  #   DatabaseCleaner.clean
  # end
end

require File.expand_path(File.join(File.dirname(__FILE__), "..", "acani"))
