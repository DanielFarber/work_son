require "pry"
require "twitter"
require "httparty"

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = "ZNJDe9p2SXoVdODQWmPPrCCMV"
  config.consumer_secret     = "v7rUql1q7BBKXvf0EYpJZJ9Mx56GDzlFKIzmE92VzRBNy3gQwz"
end

# client.search("star wars", :result_type => "recent").take(3).each do |tweet|
#   puts tweet.text
# end
# <Tweet>.user
# <Tweet>.uri.path
# <Tweet>.text
# Things of that nature


binding.pry