require 'rubygems' # for ruby-1.8
require 'mongo'
require 'ffaker'

class Time
  def self.rand(years_back=5)
    year = Time.now.year - Kernel::rand(years_back) - 1
    month = Kernel::rand(12) + 1
    day = Kernel::rand(31) + 1
    Time.local(year, month, day)
  end
end

def men_women_both
  case rand(10)
  when 0..3 then "women"
  when 4..7 then "men"
  else "both"
  end
end

# Asian, Black, Latino, Middle Eastern, Mixed, Native American, White, Other
def ethnicity
  case rand(7)
  when 0 then "asian"
  when 1 then "black"
  when 2 then "latino"
  when 3 then "middle eastern"
  when 4 then "mixed"
  when 5 then "native american"
  when 6 then "white"
  else "other"
  end
end

cx = Mongo::Connection.new
cx.drop_database("stg_acani")
db = cx.db("stg_acani")

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
# group_array = [
#   { :name => "love" },
#   { :name => "skateboard" },
#   { :name => "ice hockey" },
#   { :name => "roller hockey" },
#   { :name => "field hockey" },
#   { :name => "chess" },
#   { :name => "models" },
#   { :name => "technology" },
#   { :name => "travel" },
#   { :name => "scuba diving" },
#   { :name => "health" },
#   { :name => "skiing" },
#   { :name => "snowboarding" },
#   { :name => "fitness" },
#   { :name => "spirituality" },
#   { :name => "golf" },
#   { :name => "religion" },
#   { :name => "baseball" },
#   { :name => "soccer" },
#   { :name => "football" },
#   { :name => "tennis" },
#   { :name => "wealth" },
#   { :name => "software" },
#   { :name => "facebook" },
#   { :name => "twitter" },
#   { :name => "growth" },
#   { :name => "give back" },
# ]
# groups.insert(group_array)
# puts groups.find

# Think of smarter ways to store this data.
# Facebook may store abbreviations and then convert them to full words
# We could do this later by conversion if it makes sence
# What Facebook data are they okay with us storing?
# fb_id, location, groups, messages
users = db.collection("users")
usr_pic_grid = Mongo::Grid.new(db, "usr_pic")
usr_thb_grid = Mongo::Grid.new(db, "usr_thb")

1.upto(51) do |i|
  user = {
    :fbid => rand(4_000),
    :name => Faker::Name.name[0,10].rstrip,
    :head => Faker::Lorem.sentence(1)[0,50].rstrip,
    :about => Faker::Lorem.paragraph(1)[0,130].rstrip,
    :age => rand(20) + 16,
    :sex => rand < 0.5 ? "male" : "female",
    :likes => men_women_both,
    :sdist => rand < 0.5 ? true : false, # show_distance? (flag)
    :loc => [Faker::Geolocation.lat, Faker::Geolocation.lng],    
    # We'll implement these later
    # :favs => [],    # just store ids, not names
    # :block => [],   # just store ids, not names
    # :groups => [],  # just store ids, not names
    # :unread => [],  # store: messages, from_id, time_stamp
    :devices => [], # just store ids, not names
    :ethnic => ethnicity,
    :height => rand(50) + 140, # in cm
    :weight => rand(45) + 100, # in lbs
    :weblink => (rand < 0.3 ? '' : 'www.') + Faker::Internet.domain_name,
    :fblink => Faker::Internet.user_name,
    :updated => Time.rand.to_i,
    :laston => Time.rand.to_i,
    :onstat => rand(2) == 1 ? "online" : "offline"
  }

  id = users.insert(user)
  dir = 'pics-thbs'
  ii = "%02d" % i
  begin
    ext = 'jpg'
    pic = File.new("#{dir}/picture_#{ii}.#{ext}")
    thb = File.new("#{dir}/thumb_#{ii}.#{ext}")
  rescue
    ext = 'png'
    pic = File.new("#{dir}/picture_#{ii}.#{ext}")
    thb = File.new("#{dir}/thumb_#{ii}.#{ext}")
  end
  ext = "jpeg" if ext == "jpg"

  usr_pic_grid.put(pic, 
    :content_type => "image/#{ext}", 
    :_id          => id)

  usr_thb_grid.put(thb, 
    :content_type => "image/#{ext}", 
    :_id          => id)
end

users.create_index([[:loc, "2d"]])
# users.create_index([[:loc, "2d"], ['groups.id', 1]])

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

