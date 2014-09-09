require_relative "./lib/connection"
require_relative "./lib/classes/feed"
require_relative "./lib/classes/post"
require_relative "./lib/modules/tweeter"
require_relative "./lib/modules/tumblr"
require_relative "./lib/modules/weather"
require_relative "./lib/modules/nytimes"

loop do

	if [0, 15, 30, 33, 45].include?(Time.now.min)
		Feed.all.each do |feed|
			feed.update_stream
		end
	end


end