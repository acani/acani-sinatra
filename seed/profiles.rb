DF = File.dirname(__FILE__)
$LOAD_PATH << File.expand_path(File.join(DF, "fake_profile_pictures", "lib"))
require File.expand_path(File.join(DF, "..", "constants"))
require 'fake_profile_pictures'
require 'mongo'
require 'ffaker'

module FakeProfilePictures
  class << self
    def seed_database(database, collection)
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
      conn.drop_database(database)
      db = conn.db(database)
      
      users = db.collection("users")
      lg2_grid = Mongo::Grid.new(db, DB[:photos][:large2x]) # 640x960
      lrg_grid = Mongo::Grid.new(db, DB[:photos][:large]) # 320x480
      sq2_grid = Mongo::Grid.new(db, DB[:photos][:square2x]) # 150x150
      sqr_grid = Mongo::Grid.new(db, DB[:photos][:square]) # 75x75

      generate_readme do |p, i|
        # Insert user's picture into GridFS. Every picture has four images.
        # All images have the same picture_id.
        pic_id = lg2_grid.put(p.large2x_file, :content_type => "image/jpeg")
        pic_opts = { content_type: "image/jpeg", _id: pic_id }
        lrg_grid.put(p.large_file, pic_opts.dup) # dup because opts get deleted
        sq2_grid.put(p.square2x_file, pic_opts.dup)
        sqr_grid.put(p.square_file, pic_opts.dup)
        
        # Insert user's data into MongoDB users collection.
        users.insert({ # for most attributes: nil:do not show
          USR[:about] => p.about || Faker::Lorem.sentence,
          USR[:weight] => rand(45) + 100, # lbs
          USR[:devices] => [Faker::Product.model], # ids
          USR[:show_distance] => rand(2), # 0:hide, 1:show
          USR[:ethnicity] => rand(7), # See ethnicity method above
          USR[:favorites] => [], # ids
          USR[:interests] => [], # ids
          USR[:height] => rand(50) + 140, # (cm)
          USR[:fb_id] => rand(4_000),
          USR[:phone] => Faker::PhoneNumber.phone_number, # short_phone_number
          USR[:rel_stat] => rel_stat,
          USR[:location] => nearby,
          USR[:messages] => [], # sent/received > read/unread, sender, ts, text, etc.
          USR[:name] => Faker::Name.name[0,10].rstrip,
          USR[:online_status] => rand(4), # 0:off, 1:on, 2:busy, 3:idle
          USR[:pic_id] => pic_id.to_s,
          USR[:headline] => p.title || Faker::Name.name,
          USR[:last_online] => within_months(3), # (UNIX timestamp)
          USR[:sex] => rand(2), # 0:female, 1:male
          USR[:updated_date] => within_months(3), # (UNIX timestamp)
          USR[:fb_username] => Faker::Internet.user_name,
          USR[:likes] => rand(3), # 0:women, 1:men, 2:both
          USR[:website] => (rand < 0.3 ? '' : 'www.') + Faker::Internet.domain_name,
          USR[:block] => [], # ids
          USR[:birthday] => Time.at(within_months(180, 216)).strftime("%Y-%m-%d"),
          USR[:show_birthday] => rand(3) # 0:hide, 1:show_age, 2:show_date
        })
      end
      
      # Create a geospacial index to find users nearby with similar interests.
      # users.create_index([[USR[:location], "2d"]]) # w/o interests
      users.create_index([[USR[:location], "2d"], [USR[:interests], 1]])

      puts "Success! Regenerated fake_profile_pictures/README.md."
      puts "Seeded #{collection} collection in #{database} database with user info & photos."
      puts
    end
  end
end

# # FakeProfilePictures.seed_mongodb
# puts Photo.new("large_1234@2x.jpg").flickr_id
# puts args.db_name
# puts args.collection
