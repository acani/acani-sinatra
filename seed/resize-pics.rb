require 'rubygems' # for ruby-1.8
require 'RMagick'

Dir.chdir(File.dirname(__FILE__)+'/pics-thbs')
puts 'pwd: ' + Dir.pwd

1.upto(28) do |i|
  pi2 = Magick::Image::read("picture_#{i}@2.jpg").first
  print "#{i} "; $stdout.flush # display before newline
  gravity = [1,2,4,6,8,15,18,21,22,23,25,26].include?(i) ?
    Magick::NorthGravity : Magick::CenterGravity
  pi2.resize(320, 480).write("picture_#{i}.jpg")
  thb2 = pi2.resize_to_fill(150, 150, gravity).write("thumb_#{i}@2.jpg")
  thb = pi2.resize_to_fill(75, 75, gravity).write("thumb_#{i}.jpg")
end

puts
