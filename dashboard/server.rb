require "pry"
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
	erb(:index, { locals: { feeds: Feed.all } })
end

put "/post/tag/:id" do
	post = Post.where( {id: params["id"]} )[0]
	post.tag = params["tag"]
	post.save
	redirect("/")
end

get "/post/tag/search" do
	posts = Post.where( { tag: params["tag"] } )
	if posts.length == 0
		erb(:sorry)
	else
		erb(:search, { locals: { posts: posts, tag: params["tag"] } })
	end
end

delete "/post/:id" do
	Post.find_by( {id: params["id"]} ).update( { deleted: true } )
	redirect("/")
end

post "/feeds/new" do
	if params["source"] == "NYTimes"
		feed = Feed.create( {source: "NYTimes", search_term: "Headlines", updated_at: Time.now} )
	else
		feed = Feed.create( {source: params["source"], search_term: params["search_term"], updated_at: Time.now} )
	end
	success = feed.seed_posts
	if success
		redirect("/")
	else
		feed.destroy
		erb(:unfeed)
	end
end

get "/feeds/:id" do
	feed = Feed.find_by( { id: params["id"] } )
	posts = Post.where({ feed_id: feed.id } )
	erb(:feed, { locals: { feed: feed, posts: posts } })
end

get "/a/:id" do
	feed = Feed.find_by( { id: params["id"] } )
	posts = feed.posts
	content_type :json
	{ feed: feed, posts: posts }.to_json
end


























