require "pry"
require "active_record"
require "twitter"
require "httparty"
require_relative "../modules/nytimes"
require_relative "../modules/tweeter"
require_relative "../modules/weather"
require_relative "../modules/tumblr"

class Feed < ActiveRecord::Base

	def seed_posts
		if self.source == "NYTimes"
			result = NYTimes.seed_nytimes_posts(self.id)
		elsif self.source == "Twitter"
			result = Tweeter.seed_twitter_posts(self)
		elsif self.source == "Wunderground"
			result = Weather.seed_weather_posts(self)
    elsif self.source = "Tumblr"
      result = Tumblr.seed_posts(self)
		end
		result
	end


	def posts
		posts = Post.where( { feed_id: self.id} )
	end

end
