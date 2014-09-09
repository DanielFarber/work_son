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
			result = NYTimes.seed_posts(self.id)
		elsif self.source == "Twitter"
			result = Tweeter.seed_posts(self)
		elsif self.source == "Wunderground"
			result = Weather.seed_posts(self)
    	elsif self.source = "Tumblr"
     	 result = Tumblr.seed_posts(self)
		end
		result
	end

	def update_stream
		if Time.now.min - self.updated_at.min > 1

			if self.source == "NYTimes"
				success = false
				index = 0
				until success || index == 5
					success = NYTimes.update_stream(self)
					index += 1
				end
				self.update( { updated_at: Time.now } )

			elsif self.source == "Twitter"
				success = false
				index = 0
				until success || index == 5
					success = Tweeter.update_stream(self)
					index += 1
				end
				self.update( { updated_at: Time.now } )

			elsif self.source == "Tumblr"
				success = false
				index = 0
				until success || index == 5
					success = Tumblr.update_stream(self)
					index += 1
				end
				self.update( { updated_at: Time.now } )

			end
		end
	end


	def posts
		posts = Post.where( { feed_id: self.id} )
	end

end
