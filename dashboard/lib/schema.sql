-- CREATE TABLE feeds (
-- id serial primary key,
-- search_term varchar(60)
-- );

-- CREATE TABLE twitter_posts (
-- id serial primary key,
-- feed_id integer,
-- content varchar(180),
-- created_at date,
-- tag varchar(120),
-- twitter_id varchar(60)
-- );

-- CREATE TABLE news_posts (
-- id serial primary key,
-- feed_id integer,
-- blurb varchar(255),
-- title varchar(255),
-- created_at date,
-- times_id varchar(60)
-- );

-- CREATE TABLE weather_posts (
-- )

-- CREATE TABLE feeds (
-- id serial primary key,
-- search_term varchar(60)
-- );

CREATE TABLE feeds (
id serial primary key,
source varchar(60),
search_term varchar(60),
updated_at timestamp
);

CREATE TABLE posts (
id serial primary key,
feed_id integer,
content text,
context varchar(255),
time_data date,
url varchar(255),
tag varchar(255),
deleted boolean,
created_at timestamp
);