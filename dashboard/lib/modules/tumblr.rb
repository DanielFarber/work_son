require "httparty"
require "pry"

module Tumblr

	def self.valid_search_term?(search_term)
		search_term != ""
	end

	def self.search_returned_results?(hash)
		hash["response"] != []
	end

	def self.make_request(search_term)
		apikey = "iPPt5BOti0OookvUPFybxCvVgorCpzG7zfmWldIsM6wY2VqqVI"
		request = "http://api.tumblr.com/v2/tagged?tag=#{search_term}&filter=text&api_key=#{apikey}"
		response = HTTParty.get(request)
	end

	def self.construct_hash(post, feed_id)
		{feed_id: feed_id, content: post["caption"], context: post["blog_name"], time_data: post["date"], url: post["post_url"], tag: nil, deleted: false, created_at: Time.now}
	end

	def self.post_exists?(hash)
		Post.find_by( { url: hash[:url] } ) != nil
	end

	def self.seed_posts(feed)
		if Tumblr.valid_search_term?(feed.search_term)
			response = Tumblr.make_request(feed.search_term)
			if Tumblr.search_returned_results?(response)
				response["response"][0..9].each do |item|
					post = Tumblr.construct_hash(item, feed.id)
					Post.create(post)
				end
				return true
			else
				return false
			end
		else
			return false
		end
	end

	def self.update_stream(feed)
		response = Tumblr.make_request(feed.search_term)
		if Tumblr.search_returned_results?(response)
			response["response"][0..9].each do |item|
				post = Tumblr.construct_hash(item, feed.id)
				Post.create(post) unless Tumblr.post_exists?(post)
			end
		end
		return true
	end

end
