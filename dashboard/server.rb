require "pry"
require "httparty"
require "sinatra"
require "sinatra/reloader"
require_relative "./lib/connection"
require_relative "./lib/classes/feed"
require_relative "./lib/classes/post"

set server: 'webrick'

after do
	ActiveRecord::Base.connection.close
end

get "/" do
	erb(:index, { locals: { postmaster: Post.all.order(:id), feeds: Feed.all } })
end

put "/post/tag/:id" do
	post = Post.where( {id: params["id"]} )[0]
	post.tag = params["tag"]
	post.save
	redirect("/")
end

delete "/post/:id" do
	Post.find_by( {id: params["id"]} ).destroy
	redirect("/")
end

post "/feeds/new" do
	if params["source"] == "NYTimes"
		feed = Feed.create( {source: "NYTimes", search_term: "Headlines", updated_at: Time.now} )
	else
		feed = Feed.create( {source: params["source"], search_term: params["search_term"], updated_at: Time.now} )
	end
	posts = feed.seed_posts
	# The following could probably be refactored, possibly into an object method: [feed].has_posts?
	if !posts
		feed.destroy
		erb(:unfeed)
	elsif posts.length < 10
		posts.each {|post| post.destroy}
		feed.destroy
		erb(:unfeed)
	else
		redirect("/")
	end
end

get "/feeds/:id" do
	feed = Feed.find_by( { id: params["id"] } )
	posts = Post.where({ feed_id: feed.id } )
	erb(:feed, { locals: { feed: feed, posts: posts } })
end
