require "pry"
require "httparty"


#Most popular http://api.nytimes.com/svc/mostpopular/{version}/{resource-type}/{section}[/share-types]/{time-period}[.response-format]?api-key={your-API-key}

# newswire: http://api.nytimes.com/svc/news/v3/content/nyt/all/.json?api-key=

targ = "http://api.nytimes.com/svc/mostpopular/v2/mostviewed/world;technology;washington;science;business;sports/7.json?api-key=84eb249fa018ef4e4e959bd2e5cd8ec4:17:31478198"
response = HTTParty.get(targ)

binding.pry