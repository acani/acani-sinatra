# require 'ruby-debug'
require 'rubygems' # for ruby-1.8
require 'json/pure'
require 'sinatra'
require 'mongo'


# Configure
configure :development do
  DB = Mongo::Connection.new.db("stg_acani")
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
  
  # users.insert({'devices.id' => {'$push' => d}})
  # 
  # # create new user
  # user = {
  #   :devices => d
  # }
  # users.insert()

  "device_id = #{d};
   latitude = #{lat};
   longitude = #{lng}.\n"
end

# get all users nearby; update last_online
get '/users/:uid/:did/:lat/:lng' do
  users = DB.collection("users")

  # update lat & lng for uid
  # TODO
  uid = params[:uid]

  # return users nearby (ignore with similar groups for now)
  # http://www.mongodb.org/display/DOCS/Geospatial+Indexing
  cursor = users.find(
    {"loc" => {"$near" => [params[:lat].to_f, params[:lng].to_f]}},
    {:limit => 20})
  content_type "application/json"
  JSON.pretty_generate(cursor.to_a)
  # Example with group
  # db.places.find( { location : { $near : [50,50] }, group : 'baseball' } );
end

# hard-coded json for testing
get '/sample-json' do
  response = ''
  f = File.open("sample.json", "r") 
  f.each_line do |line|
    response += line
  end
  response
end

def pic_fs_name
  case params[:type]
  when "large"
    "usr_pic"
  else
    "usr_thb"
  end
end

# post new picture of specific user
post '/:uid/picture' do
  grid = Mongo::Grid.new(DB, pic_fs_name)
  id = grid.put(image, :content_type => params[:content_type], :metadata => {:updated => Time.now.to_i})
end

# get picture of specific user
get '/:uid/picture' do
  grid = Mongo::Grid.new(DB, pic_fs_name)
  image = grid.get(BSON::ObjectID(params[:uid]))
  content_type image.content_type
  image.read  
end

# User creates account

# User requests people nearby
