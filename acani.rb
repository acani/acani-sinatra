require 'sinatra'
require 'mongo'

# Configure
configure :development do
  DB = Mongo::Connection.new.db("acani")
end

configure :production do
  require 'uri'
  uri = URI.parse(ENV['MONGOHQ_URL'])
  conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  DB = conn.db(uri.path.gsub(/^\//, ''))
end


# create a new user and respond with user_id & users nearby
post '/users' do
  "device_id = #{params[:device_id]};
   latitude = #{params[:latitude]};
   longitude = #{params[:longitude]}.\n"
end

# get all users nearby; update last_online
get '/users/:uid/:lat/:lng' do
  persons = DB.collection("persons")

  # update lat & lng for uid
  # TODO
  uid = params[:uid]

  # return users nearby (ignore with similar groups for now)
  # http://www.mongodb.org/display/DOCS/Geospatial+Indexing
  json = ""
  persons.find({"loc" => {"$near" => [params[:lat].to_f, params[:lng].to_f]}},
               {:limit => 20}).each { |p| json += p.inspect }
  json
  # Example with group
  # db.places.find( { location : { $near : [50,50] }, group : 'baseball' } );
end

# Person creates account

# Person requests people nearby