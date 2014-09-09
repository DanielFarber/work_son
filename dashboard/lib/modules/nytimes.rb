require "httparty"

module NYTimes


	def self.get_response
		request = "http://api.nytimes.com/svc/news/v3/content/nyt/all/.json?api-key=383a34a4b72f4bad667ab0c2069baf07:8:31478198"
		response = HTTParty.get(request)
	end

	def self.is_response_valid?(response)
		response["results"] != nil
	end

	def self.construct_hash(article, feed_id)
		{feed_id: feed_id, content: article["abstract"], context: article["title"], time_data: article["published_date"], url: article["url"], created_at: Time.now, deleted: false}
	end

	def self.post_exists?(hash)
		Post.find_by( { url: hash[:url] } ) != nil
	end

	def self.seed_posts(feed_id)
		response = NYTimes.get_response
		if NYTimes.is_response_valid?(response)
			response["results"][0..9].each do |article|
				post = NYTimes.construct_hash(article, feed_id)
				Post.create(post)
			end
			true
		else
			false
		end
	end

	def self.update_stream(feed)
		response = NYTimes.get_response
		if NYTimes.is_response_valid?(response)
			response["results"].each do |article|
				post = NYTimes.construct_hash(article, feed.id)
				Post.create(post) unless NYTimes.post_exists?(post)
			end
			return true
		else
			return false
		end
	end


end