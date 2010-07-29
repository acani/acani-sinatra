require 'json'
require 'sinatra'
require 'mongo'

# Configure
configure :development do
  DB = Mongo::Connection.new.db("stg-acani")
end

configure :production do
  require 'uri'
  uri = URI.parse(ENV['MONGOHQ_URL'])
  conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  DB = conn.db(uri.path.gsub(/^\//, ''))
end

# get all users linked with the specified device
get '/users/:device_id' do |d|
  
end

# create a new user (default) and respond with user_id & users nearby
post '/users/:device_id/:latitude/:longitude' do |d, lat, lng|
  
  # persons.insert({'devices.id' => {'$push' => d}})
  # 
  # # create new user
  # user = {
  #   :devices => d
  # }
  # persons.insert()

  "device_id = #{d};
   latitude = #{lat};
   longitude = #{lng}.\n"
end

# get all users nearby; update last_online
get '/users/:uid/:did/:lat/:lng' do
  persons = DB.collection("users")

  # update lat & lng for uid
  # TODO
  uid = params[:uid]

  # return users nearby (ignore with similar groups for now)
  # http://www.mongodb.org/display/DOCS/Geospatial+Indexing
  json = ""
  persons.find({"loc" => {"$near" => [params[:lat].to_f, params[:lng].to_f]}},
               {:limit => 20}).each { |p| json += p.inspect }
  json.to_json
  # Example with group
  # db.places.find( { location : { $near : [50,50] }, group : 'baseball' } );
end

# Person creates account

# Person requests people nearby