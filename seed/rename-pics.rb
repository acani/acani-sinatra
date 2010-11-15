# Run this script after deleting a picture_#{i}@2.jpg file.
# It closes the gap by renaming all the files after it.

Dir.chdir(File.dirname(__FILE__)+'/pics-thbs')
puts 'pwd: ' + Dir.pwd

1.upto(27) do |i|
  new_names = ["picture_#{i}@2.jpg", "picture_#{i}.jpg", "thumb_#{i}.jpg"]
  old_new = new_names.map { |n| [n.sub("_#{i}", "_#{i+1}"), n] }
  next if File.exists? new_names[0]
  old_new.each do |o, n|
    print "rename #{o} to #{n}"
    unless ARGV[0] == "-i"
      File.rename(o, n)
      puts
      next
    end
    print "? y/n: "
    if STDIN.gets.chomp == "y"
      File.rename(o, n)
      puts "renamed"
    else
      puts "skipped"
    end
  end
end
