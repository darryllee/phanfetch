require 'rubygems'
require 'parallel'
require 'rss'
require 'uri'
require 'open-uri'

# puts "#{Parallel.processor_count} processor(s)"

load 'config.txt'

def fetch(url)
	filename = url.path.split('/')[-1]

	localpath = $localdir + filename

	unless File.exists?(localpath) 
#		puts "Downloading #{url}"
		Net::HTTP.start(url.host) do |http|
        		begin
	            		file = open(localpath, 'wb')
					http.request_get(url.path) do |response|
						response.read_body do |segment|
							file.write(segment)
						end
					end
			ensure
				file.close
    			end
	    	end
	end
	localpath
end

images = []
feedfiles = [] 

open($feedurl) do |rss|

    feed = RSS::Parser.parse(rss)
	feed.items.each do |item|
		images.push(URI.parse(item.link))
		feedfiles.push(URI.parse(item.link).path.split('/')[-1])
	end
end

# Slowly: images.each do | u | 

Parallel.each(images, :in_processes => 8) do | u | 
	fetch(u)
end

localfiles = Dir.glob("*.jpg")

deletedfiles = localfiles - feedfiles 

puts deletedfiles

# TODO:  delete images that are no longer in feed
# - load list of images in $localdir into array
# - subtract it from list of images in feed (need to extract that) [feedfiles]
# - delete files no longer in feed
