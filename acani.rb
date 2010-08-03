require 'ruby-debug'
require 'json'
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
  response = []
  persons.find({"loc" => {"$near" => [params[:lat].to_f, params[:lng].to_f]}},
               {:limit => 20}).each do |p|
                 p["_id"] = p["_id"].to_s
                 response << p
               end
  # response = [{"_id"=>"4c22e72a146728fe80000048", "fb_id"=>1719, "name"=>"Abelardo W", "head"=>"Dolor totam est.", "about"=>"Laudantium enim dolorem enim. Modi et qui temporibus.", "age"=>19, "sex"=>"male", "likes"=>"women", "sdis"=>true, "loc"=>[40.927955, -72.204989], "devices"=>[], "ethnic"=>"latino", "height"=>152, "weight"=>126, "weblink"=>"www.paucek.info", "fb_link"=>"ruth_langworth", "created"=>"2010-03-14T21:20:14+0000", "updated"=>"2010-06-21T08:09:13+0000", "last_on"=>"2010-06-21T08:26:46+0000"}]
  # JSON.pretty_generate(response)
  debugger
  response.to_json
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

# Person creates account

# Person requests people nearby