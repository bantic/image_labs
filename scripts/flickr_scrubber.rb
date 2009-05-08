require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'fileutils'

# quick and dirty -- needs to be cleaned up

FileUtils.mkdir_p("downloaded_flickr_files")

url = 'http://www.flickr.com/search/?q=barcelona&l=cc&ss=2&ct=0&mt=photos&page=1'
idx = 0
50.times do
  doc = Nokogiri::HTML(open(url))

  doc.css("span.photo_container a").each do |pic_link|
    new_url = "http://flickr.com#{pic_link['href']}"
    puts "getting #{new_url}"
  
    pic_doc = Nokogiri::HTML(open(new_url))
  
    all_sizes_url = "http://flickr.com" + pic_doc.css("#photo_gne_button_zoom").first['href']
    puts "getting all sizes url: #{all_sizes_url}"
  
    all_sizes_doc = Nokogiri::HTML(open(all_sizes_url))
    download_links = all_sizes_doc.css(".DownloadThis a")
    original_size_link = download_links.find {|l| l.text =~ /Download the/i }
    original_size_href = original_size_link['href']
    
    puts "original_size_href: #{original_size_href}"

    `wget #{original_size_href} -O downloaded_flickr_files/#{idx}.jpg`
    idx += 1
    
    # get next page
  end
  
  next_url = doc.css(".Next").first['href']
  url = "http://flickr.com" + next_url
end