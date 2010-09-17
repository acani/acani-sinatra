require 'rubygems' # for ruby-1.8
require 'nokogiri'
require 'open-uri'
require 'RMagick'

google = 'http://www.google.com'
index_url = google + '/images?q=hot+girl&um=1&hl=en&client=firefox-a&rls=org.mozilla:en-US:official&biw=1280&bih=647&gbv=1&as_st=y&ie=UTF-8&tbs=isch:1,isz:ex,iszw:320,iszh:480&ei=bFNYTI-vO9CDnQe7kdXYCA&start=40&sa=N'
puts "Index: #{index_url}"

i = 1
index = Nokogiri::HTML(open(index_url))
puts index_url = google + index.css("table#nav td.b a").last['href']
index.css("#ImgCont td > a").each do |l|
  page = Nokogiri::HTML(open(google+l['href']))
  source = page.css('a#thumbnail').first['href']
  blob = Net::HTTP.get(URI.parse(source))
  img = Magick::Image::from_blob(blob).first rescue next
  fmt = img.format.downcase; fmt = "jpg" if fmt == "jpeg"

  ii = "%02d" % i
  target = "picture_#{ii}.#{fmt}"
  puts "\tSaving #{source} to #{target}"
  img.write target

  thumb = img.resize_to_fill(75, 75, Magick::NorthGravity)
  thumb.write "thumb_#{ii}.#{fmt}"
  i += 1
end
