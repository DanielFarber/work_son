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
		feed = Feed.create( {source: "NYTimes", search_term: "Headlines"} )
	else
		feed = Feed.create( {source: params["source"], search_term: params["search_term"]} )
	end
	feed.seed_posts
	redirect("/")
end

get "/feeds/:id" do
	feed = Feed.find_by( { id: params["id"] } )
	posts = Post.where({ feed_id: feed.id } )
	erb(:feed, { locals: { feed: feed, posts: posts } })
end
