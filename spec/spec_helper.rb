require 'sinatra'
# require 'rack/test'

Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

require File.expand_path(File.join(File.dirname(__FILE__), "..", "acani"))

RSpec.configure do |config|

  config.before(:suite) do
    conn = Mongo::Connection.new
    conn.drop_database("acani_test")
    DB = conn.db("acani_test")
  end

  # config.after(:each) do
  #   DatabaseCleaner.clean
  # end

end
