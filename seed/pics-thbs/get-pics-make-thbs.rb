require 'rubygems' # for ruby-1.8
require 'nokogiri'
require 'open-uri'
require 'RMagick'

ARGV.each { |file|
  puts file
  img = Magick::Image::read(file).first
  puts "   Format: #{img.format}"
  puts "   Geometry: #{img.columns}x#{img.rows}"
  puts "   Class: " + case img.class_type
  when Magick::DirectClass
    "DirectClass"
  when Magick::PseudoClass
    "PseudoClass"
  end
  puts "   Depth: #{img.depth} bits-per-pixel"
  puts "   Colors: #{img.number_colors}"
  puts "   Filesize: #{img.filesize}"
  puts "   Resolution: #{img.x_resolution.to_i}x#{img.y_resolution.to_i} "+
  "pixels/#{img.units == Magick::PixelsPerInchResolution ?
  "inch" : "centimeter"}"
  if img.properties.length > 0
    puts "   Properties:"
    img.properties { |name,value|
      puts %Q|      #{name} = "#{value}"|
    }
  end
}

# google = 'http://www.google.com'
# index_url = google + '/images?q=hot+girl&um=1&hl=en&client=firefox-a&rls=org.mozilla:en-US:official&biw=1280&bih=647&gbv=1&as_st=y&ie=UTF-8&tbs=isch:1,isz:ex,iszw:320,iszh:480&ei=bFNYTI-vO9CDnQe7kdXYCA&start=40&sa=N'
# puts "Index: #{index_url}"
# 
# i = 96
# # 5.times do
#   index = Nokogiri::HTML(open(index_url))
#   puts index_url = google + index.css("table#nav td.b a").last['href']
#   index.css("#ImgCont td > a").each do |l|
#     page = Nokogiri::HTML(open(google+l['href']))
#     source = page.css('a#thumbnail').first['href']
#     blob = Net::HTTP.get(URI.parse(source))
#     img = Magick::Image::from_blob(blob).first rescue next
#     fmt = img.format.downcase; fmt = "jpg" if fmt == "jpeg"
# 
#     target = "picture_#{i}.#{fmt}"
#     puts "\tSaving #{source} to #{target}"
#     img.write target
# 
#     thumb = img.resize_to_fill(75, 75, Magick::NorthGravity)
#     thumb.write "thumb_#{i}.#{fmt}"
#     i += 1
#   end
# # end

# @db = Mongo::Connection.new.db('social_site')
# @grid = Grid.new(@db)
# 
# # Saving IO data and including the optional filename
# image = File.open("me.jpg")
# id2   = @grid.put(image, :filename => "me.jpg")
# 
# # Get the file we saved
# image = @grid.get(id2)
# 
# # Saving IO data
#   file = File.open("me.jpg")
#   id2  = @grid.put(file, 
#            :filename     => "my-avatar.jpg" 
#            :content_type => "application/jpg", 
#            :_id          => 'a-unique-id-to-use-in-lieu-of-a-random-one',
#            :chunk_size   => 100 * 1024,
#            :metadata     => {'description' => "taken after a game of ultimate"})
