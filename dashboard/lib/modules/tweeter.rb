require "twitter"

module Tweeter


	def self.get_tweets(search_term)
		client = Twitter::REST::Client.new do |config|
  		config.consumer_key    = "ZNJDe9p2SXoVdODQWmPPrCCMV"
  		config.consumer_secret = "v7rUql1q7BBKXvf0EYpJZJ9Mx56GDzlFKIzmE92VzRBNy3gQwz"
  		end
  		client.search(search_term, {}).take(10)
  	end

  	def self.construct_twitter_post(tweet, id)
  		{feed_id: id, content: tweet.text, context: tweet.user.screen_name, time_data: tweet.created_at, url: "http://www.twitter.com#{tweet.url.path}", created_at: Time.now, deleted: false}
  	end

  	def self.twitter_search_is_valid?(search_term)
  		search_term != nil &&  search_term != ""
  	end

  	def self.tweets_exist?(array)
  		array != [] && array.length == 10
  	end

  	def self.seed_twitter_posts(feed)
  		if Tweeter.twitter_search_is_valid?(feed.search_term)
  			tweets = Tweeter.get_tweets(feed.search_term)
  			if Tweeter.tweets_exist?(tweets)
  				tweets.each do |tweet|
  					Post.create(Tweeter.construct_twitter_post(tweet, feed.id))
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

  end