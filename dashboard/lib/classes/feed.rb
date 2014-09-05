require "active_record"
require "twitter"
require "httparty"

class Feed < ActiveRecord::Base

	$client = Twitter::REST::Client.new do |config|
  	config.consumer_key    = "ZNJDe9p2SXoVdODQWmPPrCCMV"
  	config.consumer_secret = "v7rUql1q7BBKXvf0EYpJZJ9Mx56GDzlFKIzmE92VzRBNy3gQwz"
  end

	def seed_posts
		self.seed_nytimes_posts if self.source == "NYTimes"
		self.seed_twitter_posts if self.source == "Twitter"
		self.seed_weather_posts if self.source == "Wunderground"
	end

	def seed_nytimes_posts
		request = "http://api.nytimes.com/svc/news/v3/content/nyt/all/.json?api-key=383a34a4b72f4bad667ab0c2069baf07:8:31478198"
		response = nil
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
		selection = $client.search(self.search_term, {}).take(10)

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

	def seed_weather_posts
		location = self.search_term.split(",")
		request = ("http://api.wunderground.com/api/418ccbe65bea6581/forecast10day/q/#{location[0]}/#{location[1]}.json")
		response = nil
		until response && response["forecast"]
			response = HTTParty.get(request)
		end

		selection = response["forecast"]["simpleforecast"]["forecastday"][0..9]	
		selection.each_with_index do |day, index|
			date = "#{day["date"]["monthname"]} #{day["date"]["day"]}, #{day["date"]["year"]}"
			post = {
				feed_id: self.id,
				content: "High: #{day["high"]["fahrenheit"]} Low: #{day["low"]["fahrenheit"]}",
				context: response["forecast"]["txt_forecast"]["forecastday"][index * 2]["fcttext"],
				time_data: date,
				url: "http://www.wunderground.com/cgi-bin/findweather/hdfForecast?query=#{location[1]}%2C+#{location[0]}"
			}
			Post.create(post)
		end
	end

end
