require 'rubygems' # for ruby-1.8
require 'net/http'
require 'json'
require 'mongo'
require 'ffaker'

script_dir = File.dirname(__FILE__)
pic_dir = script_dir + '/pics-thbs'
git_dir = "https://github.com/acani/acani-sinatra/raw/master/seed/pics-thbs"
require script_dir + '/../constants.rb'
require script_dir + '/config.rb'

# Return a Unix timestamp within x days from now.
def within_months(month_range, months_since_now=0)
  Time.now.to_i - months_since_now*2_629_743 - rand(month_range*2_629_743)
end

# Return an array [lat, lng] of a location nearby (lat, lng).
def nearby(lat=37.332, lng=-122.031)
  [lat+rand(40)/1000.0-0.02, lng+rand(40)/1000.0-0.02]
end

def rel_stat
  case rand(10)
  when 0 then ""
  when 1 then "Single"
  when 2 then "In a Relationship"
  when 3 then "Engaged"
  when 4 then "Married"
  when 5 then "It's Complicated"
  when 6 then "In an Open Relationship"
  when 7 then "Widowed"
  when 8 then "Separated"
  when 9 then "Divorced"
  end
end

conn = Mongo::Connection.new
conn.drop_database("acani")
db = conn.db("acani")

# The devices collection stores data about the device
# devices = db.collection("devices")
# device = {
#   :id => ,
#   :users => [
#     :id => "1231jfkj123",
#     :name => "Matt"
#   ], # ids & names only
#   :os => 4
#   # ...
# }

# # TODO: add more groups and nest subgroups within supergroups
# groups = db.collection("groups")
# groups.remove # start fresh in case not empty
# require './groups' # groups array
# groups.insert(group_array)
# puts groups.find


# # refs:
# # http://www.flickr.com/services/api/
# # https://github.com/ctagg/flickr/blob/master/lib/flickr.rb
# module Flickr
#   class Client
#     attr_accessor :api_key
#
#     REST_URI = "http://www.flickr.com/services/rest"
#
#     def method_missing(method_id, args={})
#       request(method_id, args)
#     end
#
#     def request(method, params={})
#       url = request_url(method, params)
#       response = JSON.parse(open(URI.encode(uri))[14..-2]) # strip JSONP padding
#       raise response['err']['msg'] if response['stat'] != 'ok'
#       response
#     end
#
#     def request_url(method, params={})
#       method = 'flickr.' + method.to_s.tr('_', '.')
#       url = "#{REST_URI}/?api_key=#{api_key}&format=json&method=#{method}"
#       unless params.empty?
#         url + '&' + params.map({ |k, v| "#{k}={v}" }).join("&")
#       end
#     end
#   end
#
#   class Photo
#     attr_accessor :id, :title, :owner
#   end
#
#   class User
#     attr_accessor :nsid, :username, :realname
#   end
# end

# http://www.flickr.com/services/rest/?method=flickr.photos.getInfo&photo_id=4994965909&format=json&api_key=

# What Facebook data are they okay with us storing?
# fb_id, location, groups, messages
users = db.collection("users")
usr_pi2_grid = Mongo::Grid.new(db, "usr_pi2") # 640x960 for iPhone 4
usr_pic_grid = Mongo::Grid.new(db, "usr_pic") # 320x480
usr_th2_grid = Mongo::Grid.new(db, "usr_th2") # 150x150 for iPhone 4
usr_thb_grid = Mongo::Grid.new(db, "usr_thb") # 75x75

flickr = 'http://www.flickr.com'
flickr_photo_ids = [
  "5174950991", #1
  "3788426000",
  "4530910556",
  "4452457288",
  "3259370999", #5
  "3244887018",
  "3936813347",
  "2369151434",
  "3936777541",
  "2368320493", #10
  "5100437401",
  "3937523554",
  "3679345595",
  "5172802343",
  "4994965909", #15
  "3474008237",
  "5064560501",
  "4897110371",
  "4890165748",
  "4733974817", #20
  "4476799140",
  "4476798352",
  "3936827307",
  "3555474750",
  "3377864339", #25
  "3156504080",
  "2890368131",
  "3936883765"
]

attr_doc = <<EOF
Photo Credits
=============

Every photo in this directory is a cropped and/or resized derivative of the
original. On **November 13, 2010**, all original photos were downloaded from
[Flickr][] and licensed under either the [Attribution][by] or
[Attribution-ShareAlike][by-sa] [Creative Commons license][ccl].

*Note*: the order below corresponds to the numbers in the file names. For
example, number 3 corresponds to the files: `picture_3.jpg`, `picture_3@2.jpg`,
`thumb_3.jpg`, and `thumb_3@2.jpg`.

EOF

link_text = <<EOF

[Flickr]: http://www.flickr.com/
[by]: http://creativecommons.org/licenses/by/2.0/
[by-sa]: http://creativecommons.org/licenses/by-sa/2.0/
[ccl]: http://creativecommons.org/licenses/

EOF

# Create users for photos and insert both into GridFS.
1.upto(28) do |i|
  print "#{i} "; $stdout.flush # display before newline

  # Add photo info to attribution doc.
  photo_id = flickr_photo_ids[i-1]
  uri = "#{flickr}/services/rest/?method=flickr.photos.getInfo&photo_id=#{photo_id}&format=json&api_key=#{API_KEY}"
  response = Net::HTTP.get_response(URI.parse(uri)).body.to_s
  meta = JSON.parse(response[14..-2]) # strip JSONP padding

  unless meta["stat"] == "ok"
    raise "photo_id: #{photo_id}: error: #{meta["code"]} - #{meta["message"]}."
    next
  end

  photo = meta["photo"];
  owner = photo["owner"];
  photo_title = photo["title"]["_content"]
  photo_url = photo["urls"]["url"][0]["_content"]
  photo_license = case photo["license"].to_i
    when 4 then "Attribution"
    when 5 then "Attribution-ShareAlike"
    else raise photo_id + ': license: ' + photo["license"]
  end
  photo_license = "Creative Commons — #{photo_license} 2.0 Generic"
  about = "The overlaid textual data about the person in this photo and its thumbnail was fabricated and, thus, is very unlikely to be true. This photo and its thumbnail are cropped and/or resized derivatives of \"#{photo_title}\" by #{owner["realname"]} (#{owner["username"]}) on Flickr. License: #{photo_license}. Accessed 13 Nov. 2010. #{photo_url}"

  attr_doc += <<EOF
  #{i}. ![#{photo_title}][#{i}t] "[#{photo_title}][#{i}p]." Photograph by [#{owner["realname"]} (#{owner["username"]}) on Flickr][#{i}o]. License: [#{photo_license}][#{photo["license"] == "4" ? "by" : "by-sa"}].

EOF

  link_text += <<EOF
[#{i}t]: #{git_dir}/thumb_#{i}.jpg
[#{i}p]: #{photo_url}
[#{i}o]: #{flickr}/people/#{owner["nsid"]}
EOF

  # Load user's photos from their files.
  pi2 = File.new("#{pic_dir}/picture_#{i}@2.jpg")
  pic = File.new("#{pic_dir}/picture_#{i}.jpg")
  th2 = File.new("#{pic_dir}/thumb_#{i}@2.jpg")
  thb = File.new("#{pic_dir}/thumb_#{i}.jpg")

  # Insert user's photos into GridFS.
  pic_id = usr_pi2_grid.put(pi2, :content_type => "image/jpeg")
           usr_pic_grid.put(pic, :content_type => "image/jpeg", :_id => pic_id)
           usr_th2_grid.put(th2, :content_type => "image/jpeg", :_id => pic_id)
           usr_thb_grid.put(thb, :content_type => "image/jpeg", :_id => pic_id)

  # Insert user's data into MongoDB users collection.
  users.insert({ # for most attributes: 0:do not show
    USR[:about] => about,
    USR[:weight] => rand(45) + 100, # lbs
    USR[:devices] => [], # ids
    USR[:show_distance] => rand(2), # 0:hide, 1:show
    USR[:ethnicity] => rand(7), # See ethnicity method above
    USR[:favorites] => [], # ids
    USR[:groups] => [], # ids
    USR[:height] => rand(50) + 140, # (cm)
    USR[:fb_id] => rand(4_000),
    USR[:phone] => Faker::PhoneNumber.phone_number, # short_phone_number
    USR[:rel_stat] => rel_stat,
    USR[:location] => nearby,
    USR[:messages] => [], # sent/received > read/unread, sender, ts, text, etc.
    USR[:name] => Faker::Name.name[0,10].rstrip,
    USR[:online_status] => rand(4), # 1:off, 2:on, 3:busy, 4:idle
    USR[:pic_id] => pic_id.to_s,
    USR[:headline] => photo_title,
    USR[:last_online] => within_months(3), # (UNIX timestamp)
    USR[:sex] => rand(3), # 1:female, 2:male
    USR[:updated] => within_months(3), # (UNIX timestamp)
    USR[:fb_username] => Faker::Internet.user_name,
    USR[:likes] => rand(4), # 1:women, 2:men, 3:both
    USR[:website] => (rand < 0.3 ? '' : 'www.') + Faker::Internet.domain_name,
    USR[:block] => [], # ids
    USR[:birthday] => Time.at(within_months(180, 216)).strftime("%Y-%m-%d"),
    USR[:show_birthday] => rand(3) # 0:hide, 1:show_date, 2:show_age
  })
end

users.create_index([[USR[:location], "2d"]])
# users.create_index([[:loc, "2d"], ['groups.id', 1]])

puts
puts doc = attr_doc + link_text
File.open(pic_dir+'/README.md', 'w') { |f| f.write(doc) }


# m = Mongo::Connection.new # (optional host/port args)
# m.database_names.each { |name| puts name }
# m.database_info.each { |info| puts info.inspect}

# Users
# Devices
#
# class Device(db.Model):
#   id = db.StringProperty(required=True)
#   location = db.GeoPtProperty()
#
# class User(polymodel.PolyModel):
#   name = db.StringProperty()
#   headline = db.StringProperty()
#   about = db.StringProperty(multiline=True)
#   age = db.IntegerProperty()
#   facebook = db.LinkProperty()
#   show_dist = BooleanProperty(default=True)
#   created = db.DateTimeProperty(auto_now_add=True)
#   updated = db.DateTimeProperty(auto_now_add=True)
#   last_online = db.DateTimeProperty(auto_now_add=True)
#
# class Person(User):
#   height = db.IntegerProperty()
#   weight = db.IntegerProperty()
#   ethnicity = db.StringProperty(required=True,
#                                 choices=set(["Asian", "Black", "Latino",
#                                              "Middle Eastern", "Mixed",
#                                              "Native American", "White",
#                                              "Other"]))
#
# class Company(User):
