require "active_record"
require "twitter"
require "httparty"

class Feed < ActiveRecord::Base

	def seed_posts
		self.seed_nytimes_posts if self.source == "NYTimes"
		self.seed_twitter_posts if self.source == "Twitter"
		self.seed_weather_posts if self.source == "Wunderground"
	end

	def seed_nytimes_posts
		request = "http://api.nytimes.com/svc/news/v3/content/nyt/all/.json?api-key=383a34a4b72f4bad667ab0c2069baf07:8:31478198"
		response = nil
		# This next bit could have ominous results
		# There must be a better way to assure a succesful post seeding
		# Although, at this point, it's the same request everytime and if it works once it should always work
		until response && response["results"]
			response = HTTParty.get(request)
		end
		selection = response["results"][0..9]

		selection.each do |article|
			post = {
				feed_id: self.id,
				content: article["abstract"],
				context: article["title"],
				time_data: article["published_date"],
				url: article["url"]
			}
			Post.create(post)
		end
	end

	def seed_twitter_posts
		client = Twitter::REST::Client.new do |config|
  		config.consumer_key    = "ZNJDe9p2SXoVdODQWmPPrCCMV"
  		config.consumer_secret = "v7rUql1q7BBKXvf0EYpJZJ9Mx56GDzlFKIzmE92VzRBNy3gQwz"
  		end
  		# I have the same complaint here as with all the seed methods- I don't like these conditions being here.
  		# maybe there should be a method that makes sure a valid API request can be made?
		unless self.search_term == ""
			selection = client.search(self.search_term, {}).take(10)
			selection.each do |tweet|
				post = {
					feed_id: self.id,
					content: tweet.text,
					context: tweet.user.screen_name,
					time_data: tweet.created_at,
					url: "http://www.twitter.com#{tweet.url.path}"
				}
				Post.create(post)
			end
		end
	end

	def seed_weather_posts
		location = URI.encode(self.search_term).split(",%20")
		request = ("http://api.wunderground.com/api/418ccbe65bea6581/forecast10day/q/#{location[1]}/#{location[0]}.json")
		response = HTTParty.get(request)

		if response["forecast"]
			selection = response["forecast"]["simpleforecast"]["forecastday"][0..9]	
			selection.each_with_index do |day, index|
				date = "#{day["date"]["monthname"]} #{day["date"]["day"]}, #{day["date"]["year"]}"
				post = {
					feed_id: self.id,
					content: "High: #{day["high"]["fahrenheit"]} Low: #{day["low"]["fahrenheit"]}",
					context: response["forecast"]["txt_forecast"]["forecastday"][index * 2]["fcttext"],
					time_data: date,
					url: "http://www.wunderground.com/cgi-bin/findweather/hdfForecast?query=#{location[0]}%2C+#{location[1]}"
				}
				Post.create(post)
			end
		end
	end

end
