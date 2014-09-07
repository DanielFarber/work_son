require_relative "./lib/connection"
require_relative "./lib/classes/feed"
require_relative "./lib/classes/post"

# I anticipate that a lot of the subsequent refactoring will involve using class and object methods

# Make sure that the loop doesn't consistently update for the period where those conditions are true.
loop do

	if Time.now.min == 24
		Feed.all.each do |feed|
			if feed.source == "Twitter"
			#This is mostly copied directly from the object method- it might help if it was broken up into smaller methods
			client = Twitter::REST::Client.new do |config|
				config.consumer_key    = "ZNJDe9p2SXoVdODQWmPPrCCMV"
				config.consumer_secret = "v7rUql1q7BBKXvf0EYpJZJ9Mx56GDzlFKIzmE92VzRBNy3gQwz"
		  	end
			selection = client.search(feed.search_term, {}).take(10)
			selection.each do |tweet|
				if Post.where( { url: "http://www.twitter.com#{tweet.url.path}"} ).length == 0
					post = {
						feed_id: feed.id,
						content: tweet.text,
						context: tweet.user.screen_name,
						time_data: tweet.created_at,
						url: "http://www.twitter.com#{tweet.url.path}"
						created_at: Time.now,
						deleted: false
					}
					Post.create(post)
				end
			end
			elsif feed.source == "NYTimes"
				request = "http://api.nytimes.com/svc/news/v3/content/nyt/all/.json?api-key=383a34a4b72f4bad667ab0c2069baf07:8:31478198"
				response = nil
				# Read the above comments and the comments in the class method- they apply here as well.
				
				response = HTTParty.get(request)
				selection = response["results"][0..9]

				selection.each do |article|
					if Post.where( { url: article["url"] } ).length == 0
						post = {
							feed_id: feed.id,
							content: article["abstract"],
							context: article["title"],
							time_data: article["published_date"],
							url: article["url"],
							created_at: Time.now,
							deleted: false
						}
						Post.create(post)
					end
				end
			elsif feed.source == "Wunderground"
				location = URI.encode(feed.search_term).split(",%20")
				request = ("http://api.wunderground.com/api/418ccbe65bea6581/forecast10day/q/#{location[1]}/#{location[0]}.json")
				response = HTTParty.get(request)

				if response["forecast"]
					selection = response["forecast"]["simpleforecast"]["forecastday"][0..9]	
					selection.each_with_index do |day, index|
						date = "#{day["date"]["monthname"]} #{day["date"]["day"]}, #{day["date"]["year"]}"
						post = {
							feed_id: feed.id,
							content: "High: #{day["high"]["fahrenheit"]} Low: #{day["low"]["fahrenheit"]}",
							context: response["forecast"]["txt_forecast"]["forecastday"][index * 2]["fcttext"],
							time_data: date,
							url: "http://www.wunderground.com/cgi-bin/findweather/hdfForecast?query=#{location[0]}%2C+#{location[1]}",
							created_at: Time.now,
							deleted: false
						}
						unless Post.find_by( { time_data: post[:time_data] } )
							Post.create(post)
						end
					end
				end
			end
			feed.update( { updated_at: Time.now } )
		end
		sleep 120
	end
end
