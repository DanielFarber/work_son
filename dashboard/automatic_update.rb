require_relative "./lib/connection"
require_relative "./lib/classes/feed"
require_relative "./lib/classes/post"

# I anticipate that a lot of the subsequent refactoring will involve using class and object methods


loop do

	if Time.now.min == 30
		Feed.all.each do |feed|
			if feed.source == "Twitter"
				#This is mostly copied directly from the object method- it might help if it was broken up into smaller methods
				client = Twitter::REST::Client.new do |config|
		  		config.consumer_key    = "ZNJDe9p2SXoVdODQWmPPrCCMV"
		  		config.consumer_secret = "v7rUql1q7BBKXvf0EYpJZJ9Mx56GDzlFKIzmE92VzRBNy3gQwz"
			  	end
				selection = client.search(feed.search_term, {}).take(10)
				selection.each do |tweet|
					unless Post.where( { url: "http://www.twitter.com#{tweet.url.path}"} ).length == 0
						post = {
							feed_id: feed.id,
							content: tweet.text,
							context: tweet.user.screen_name,
							time_data: tweet.created_at,
							url: "http://www.twitter.com#{tweet.url.path}"
						}
						Post.create(post)
					end
				end
				feed.update( { updated_at: Time.now } )
			elsif feed.source == "NYTimes"
				request = "http://api.nytimes.com/svc/news/v3/content/nyt/all/.json?api-key=383a34a4b72f4bad667ab0c2069baf07:8:31478198"
				response = nil
				# Read the above comments and the comments in the class method- they apply here as well.
				until response && response["results"]
					response = HTTParty.get(request)
				end
				selection = response["results"][0..9]

				selection.each do |article|
					unless Post.find_by( { url: article["url"] } )
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
			end
		end
	end

	if [6, 18].include? Time.now.hour
		








end