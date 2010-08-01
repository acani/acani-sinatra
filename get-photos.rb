require 'nokogiri'
require 'open-uri'

google = 'http://www.google.com'
doc = Nokogiri::HTML(open(google+'/images?um=1&hl=en&client=firefox-a&rls=org.mozilla:en-US:official&biw=1280&bih=374&as_st=y&tbs=isch:1,isz:ex,iszw:320,iszh:480&q=iphone+photo+sexy+girl&btnG=Search&aq=f&aqi=&oq=&gs_rfai=&gbv=1&ei=yXRUTP61DZaLnAe7wsnWBQ'))

doc.css("#ImgCont td > a").each do |l|
  img = Nokogiri::HTML(open(google+l['href']))
  puts img.css('title').first.content.gsub ' Google Image Result for ', ''

  open("fun.jpg", "wb") do |f|
    f.write(open())
  end

  Net::HTTP.start("static.flickr.com") { |http|
    resp = http.get("/92/218926700_ecedc5fef7_o.jpg")
  }
  puts "Yay!!"
  # src = img.css("ul.il_ul > li > a").first['href']
  # puts google+src
  break
end
