require "pry"
require "httparty"


#Most popular http://api.nytimes.com/svc/mostpopular/{version}/{resource-type}/{section}[/share-types]/{time-period}[.response-format]?api-key={your-API-key}

# newswire: http://api.nytimes.com/svc/news/v3/content/nyt/all/.json?api-key=

targ = "http://api.nytimes.com/svc/news/v3/content/nyt/all/.json?api-key=383a34a4b72f4bad667ab0c2069baf07:8:31478198"


binding.pry