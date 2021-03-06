<!DOCTYPE html>
<html>
<head>
  <title>Dashboard</title>
  <link rel="stylesheet" type="text/css" href="style.css" />
  <link href='http://fonts.googleapis.com/css?family=Roboto+Slab:100' rel='stylesheet' type='text/css'>
</head>
<body>
  <div>Add a feed to your dashboard
    <form action="/feeds/new" method="POST">
      <select name="source">
        <option value="Twitter">Twitter</option>
        <option value="NYTimes">The New York Times</option>
        <!-- I might want to change this to "Weather" or something (but it would have to be changed a few other places, too-->
        <option value="Wunderground">Weather</option>
        <option value="Tumblr">Tumblr</option>
      </select>
      <div>Add a city and state to your Weather feed, or a subject for your Twitter or Tumblr stream.</div>
      <input type="text" name="search_term">
      <button>Stream</button>
    </form>
  </div>
  <div>Search for posts by tag
    <form action="/post/tag/search" method="GET">
      <input type="text" name="tag" placeholder="<<tag>>">
      <button>Search</button>
    </form>
  </div>

  <% feeds.each do |feed| %>
  <h2><a href="/feeds/<%= feed.id %>/1"><%= "#{feed.source} #{feed.search_term}" %></a></h2>
  <div class="feed">
    <% feed.posts.where( { deleted: false } ).order( { created_at: :desc } )[0..9].each do |post| %>
    <div class="post">
      <!-- I wonder if there's any way to make this all shorter? -->
      <!-- Perhaps it can be done by implementing a child template for each feed.source -->
      <div><%= feed.search_term %></div>
      <div><a href="<%= post.url %>"><%= post.context %></a></div>
      <div><%= Post.link_to_text(post.content) unless post.content == nil %></div>
      <div><%= post.time_data %></div>
      <div>
        <% if post.tag %>
        <form action="/post/tag/<%= post.id %>" method="POST">
          <input type="hidden" name="_method" value="PUT">
          <input type="text" name="tag" placeholder="<%= post.tag %>">
          <button>Change Tag</button>
        </form>
        <% else %>
        <form action="/post/tag/<%= post.id %>" method="POST">
          <input type="hidden" name="_method" value="PUT">
          <input type="text" name="tag" placeholder="None">
          <button>Add Tag</button>
        </form>
        <% end %>
        <form action="post/<%= post.id %>" method="POST">
          <input type="hidden" name="_method" value="DELETE">
          <button>Delete this post</button>
        </form>
      </div>
    </div>
    <% end %>
  </div>
  <% end %>
</body>
</html>