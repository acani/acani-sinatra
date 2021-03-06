require 'sinatra'
require 'json'
require 'mongo'
# require 'haml'
require './constants.rb'

Dir["./models/*.rb"].each {|f| require f} # require models

configure :test do
  require 'ruby-debug'
  DB = Mongo::Connection.new.db("acani-test")
end

configure :development do
  require 'ruby-debug'
  DB = Mongo::Connection.new.db("acani-staging") # should be acani
end

configure :staging, :production do
  require 'uri'
  uri = URI.parse(ENV['MONGOHQ_URL'])
  conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
  DB = conn.db(uri.path.gsub(/^\//, ''))
end

USERS = DB.collection("u")
set :haml, {:format => :html5} # default Haml format was :xhtml. Is it still?

# # Get all users linked with the specified device.
# # Currently, a user may only connect via FBConnect, so this is not ready.
# get '/users/:device_id' do |d|
#   "welcome!"
# end

# Return a JSON array of all interests.
get '/interests' do
  interests = DB.collection("interests")
  content_type "application/json"
  JSON.pretty_generate(interests.find.to_a)
end

# 1. User signs in. Respond with their info if found.
get "/users/:device_id" do |device_id|
  content_type "application/json"
  # USERS.insert({device_id: "123", updated_time: "2011-09-21"})

  user = User.find_by_device_id(device_id)
  # sleep 2 # mock a slow connection
  # If found, send device the updated_time so it knows user info is up to date.
  # Else, send 0 to let the device know that user doesn't yet exist.
  user.nil? ? "0" : "\"#{user.updated_time}\""
end

# # 2. Create a new user (default) and respond with user_id & users nearby.
# post '/users/:device_id/:latitude/:longitude' do |d, lat, lng|
#   
# end

# Get all users nearby with specified interest. Update last_online.
get '/interests/:interest_id/users/:device_id/:lat/:lng' do
  content_type "application/json"

  device_id = params[:device_id]

  # # Update my location & last_online by user_id & return me
  # if (user_id = params[:user_id]) != '0' && # not new user
  #    (me = USERS.find({"_id" => (user_id = BSON::ObjectId(user_id))}).first)
  #   USERS.update({"_id" => user_id}, {"$set" => updates})
  #   me.merge updates
  # else # create new user
  #   # insert_with_device_id(params[:device_id]) # add to POST method too.
  #   me = {USR[:devices] => [params[:device_id]]}.merge updates
  #   USERS.insert(me)
  # end

  # How should we store timestamps?
  # "created" : { "d" : "2010-03-29", "t" : "20:15:34" }
  # "created" : "12343545234"

  user = User.find_by_device_id(device_id)
  return "0" if user.nil?

  # If user exists, update: location, last_online, updated_time.
  interest_id = params[:interest_id]
  lat = params[:lat].to_f
  lng = params[:lng].to_f
  now = Time.now # fix time
  updates = {USR[:location] => [lat, lng], USR[:last_online] => now,
      USR[:updated_time] => now}  
  USERS.update({devices: device_id}, {"$set" => updates})

  # Return users nearby with similar interest.
  # http://www.mongodb.org/display/DOCS/Geospatial+Indexing
  nearby_users = interest_id == "0" ?
    USERS.find({USR[:location] => {"$near" => [lat, lng]}}, {:limit => 200}) :
    USERS.find({USR[:location] => {"$near" => [lat, lng]},
                USR[:interests] => interest_id}, {:limit => 200})

  JSON.pretty_generate(nearby_users.to_a)
  # JSON.pretty_generate(([me]+nearby_users.to_a).map { |u|
  #   u.merge "created" => (u["_id"] || u[:_id]).generation_time.to_i })
  # JSON.pretty_generate([me]+nearby_users.to_a)
end

# Update a user's location in the background. Should be PUT, but GET is easier.
get "/users/:user_id/location/:latitude/:longitude" do
  # User.new(params[:user_id]).update_location(params[:x], params[:y])
  USERS.update({:_id => BSON::ObjectId(params[:user_id])}, {
    USR[:location] => [params[:latitude], params[:longitude]],
    USR[:updated_time] => Time.now}
end

# Handle a user's request to add a new interest.
post '/interests/:interest_id' do
  USERS.update({:_id => BSON::ObjectId(params[:user_id])},
      {:$addToSet => {USR[:interests] => params[:interest_id]}}) # add unless exists
  "OK"
end

# Handle a user's request to remove a new interest.
delete '/interests/:interest_id' do
  USERS.update({:_id => BSON::ObjectId(params[:user_id])},
      {:$pull => {USR[:interests] => params[:interest_id]}})
  "OK"
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
  type = params[:type] == "large" ? params[:type] : "square"
  type << params[:retna] if params[:retna] == "2x"
  COL[:photos][type.to_sym]
end

# # Get a specific object's picture.
# get '/:obj_id/picture' do
# end

# Get a specific picture.
get '/pictures/:pic_id' do
  grid = Mongo::Grid.new(DB, pic_fs_name)
  begin
    image = grid.get(BSON::ObjectId(params[:pic_id]))
    content_type image.content_type
    image.read
  rescue
    ""
  end
end

# get form to edit object from browser
get '/:obj_id/edit' do
  @obj_id = params[:obj_id]
  return haml(:edit)
end


module Mongo
  class Grid
    def put_get_md5(data, opts={})
      opts.merge!(default_grid_io_opts)
      file = GridIO.new(@files, @chunks, nil, 'w', opts=opts)
      file.write(data)
      file.close
      file.server_md5
    end
  end
end

# update object's picture & profile info
put '/:obj_id' do
  obj_id = BSON::ObjectId(params.delete "obj_id")
  params.delete "_method" # delete param added by sinatra

  # Update thb & pic if sent.
  if (thb = params.delete "thb") && (thb_tmp = thb[:tempfile]) &&
    (pic = params.delete "pic") && (pic_tmp = pic[:tempfile])

    def put_img(img, opts={})
      grid = Mongo::Grid.new(DB, opts[:fs_name])
      grid.delete(opts[:_id])
      grid.put_get_md5(img.read,
          :_id => opts[:_id], :content_type => opts[:content_type])
    end

    opts = {:_id => obj_id, :content_type => pic[:type]} # == thb content_type
    thb_md5 = put_img(thb_tmp, opts.merge({:fs_name => "usr_thb"}))
    pic_md5 = put_img(pic_tmp, opts.merge({:fs_name => "usr_pic"}))

    params.merge!({"thb_md5" => thb_md5, "pic_md5" => pic_md5})
    # thb_grid = Mongo::Grid.new(DB, 'usr_thb')
    # thb_grid.delete(obj_id)
    # thb = thb_grid.put(thb_tmp.read, :_id => obj_id, :content_type => pic[:type])
  end

  # convert numeric Strings to Fixnums
  params.each_pair {|k, v| params[k] = Integer(v) rescue v }
  USERS.update({"_id" => obj_id}, {"$set" => params})

  "OK"
end

# delete object
delete '/:obj_id' do
  obj_id = BSON::ObjectId(params[:obj_id])

  grid = Mongo::Grid.new(DB, "usr_pic")
  grid.delete(obj_id)
  grid = Mongo::Grid.new(DB, "usr_thb")
  grid.delete(obj_id)

  USERS.remove({:_id => obj_id})
  "OK"
end
