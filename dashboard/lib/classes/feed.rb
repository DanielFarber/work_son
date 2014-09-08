require "pry"
require "active_record"
require "twitter"
require "httparty"

class Feed < ActiveRecord::Base

	def seed_posts
		if self.source == "NYTimes"
			result = self.seed_nytimes_posts
		elsif self.source == "Twitter"
			result = self.seed_twitter_posts
		elsif self.source == "Wunderground"
			result = self.seed_weather_posts
		end
		result
	end

	def get_nytimes_response
		request = "http://api.nytimes.com/svc/news/v3/content/nyt/all/.json?api-key=383a34a4b72f4bad667ab0c2069baf07:8:31478198"
		response = HTTParty.get(request)
	end

	def is_nytimes_response_valid?(response)
		response["results"] != nil
	end

	def construct_nytimes_hash(article)
		{feed_id: self.id, content: article["abstract"], context: article["title"], time_data: article["published_date"], url: article["url"], created_at: Time.now, deleted: false}
	end

	def ny_times_post_exists?(hash)
		Post.find_by( { url: hash[:ur] } ) == nil
	end

	def seed_nytimes_posts
		response = self.get_nytimes_response
		if self.is_nytimes_response_valid?(response)
			response["results"][0..9].each do |article|
				Post.create(self.construct_nytimes_hash(article))
			end
			true
		else
			false
		end
	end


	def get_tweets
		client = Twitter::REST::Client.new do |config|
  		config.consumer_key    = "ZNJDe9p2SXoVdODQWmPPrCCMV"
  		config.consumer_secret = "v7rUql1q7BBKXvf0EYpJZJ9Mx56GDzlFKIzmE92VzRBNy3gQwz"
  		end
  		client.search(self.search_term, {}).take(10)
  	end

  	def construct_twitter_post(tweet)
  		{feed_id: self.id, content: tweet.text, context: tweet.user.screen_name, time_data: tweet.created_at, url: "http://www.twitter.com#{tweet.url.path}", created_at: Time.now, deleted: false}
  	end

  	def twitter_search_is_valid?
  		self.search_term != nil &&  self.search_term != ""
  	end

  	def tweets_exist?(array)
  		array != [] && array.length == 10
  	end

  	def seed_twitter_posts
  		if self.twitter_search_is_valid?
  			tweets = self.get_tweets
  			if self.tweets_exist?(tweets)
  				tweets.each do |tweet|
  					Post.create(self.construct_twitter_post(tweet))
  				end
  				result = true
  			else
  				result = false
  			end
  		else
  			result = false
  		end
  		result
  	end




  	def validate_wunderground_search
  		if self.search_term.include?(",")
  			location = self.search_term.split(",")
  			location = location.collect { |item| URI.encode(item) }
  		else
  			false
  		end
  	end

  	def get_forecast(array)
  		request = "http://api.wunderground.com/api/418ccbe65bea6581/forecast10day/q/#{array[1]}/#{array[0]}.json"
  		response = HTTParty.get(request)
  	end

  	def got_forecast?(array)
  		array.include?("forecast")
  	end


  	def construct_weather_post(forecast, day, location, index)
  		date = "#{day["date"]["monthname"]} #{day["date"]["day"]}, #{day["date"]["year"]}"
  		{feed_id: self.id, content: "High: #{day["high"]["fahrenheit"]} Low: #{day["low"]["fahrenheit"]}", context: forecast["forecast"]["txt_forecast"]["forecastday"][index * 2]["fcttext"], time_data: date, url: "http://www.wunderground.com/cgi-bin/findweather/hdfForecast?query=#{location[0]}%2C+#{location[1]}", created_at: Time.now, deleted: false}
  	end


  	def seed_weather_posts
  		location = self.validate_wunderground_search
  		if location
  			forecast = self.get_forecast(location)
  			if got_forecast?(forecast)
  				forecast["forecast"]["simpleforecast"]["forecastday"][0..9].each_with_index do |day, index|
  					post = construct_weather_post(forecast, day, location, index)
  					Post.create(post)
  				end
  				true
  			else
  				false
  			end
  		else
  			false
  		end
  	end

	def posts
		posts = Post.where( { feed_id: self.id} )
	end

end
