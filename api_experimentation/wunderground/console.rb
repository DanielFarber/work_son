require "pry"
require "httparty"

# http://api.wunderground.com/api/418ccbe65bea6581/forecast10day/q/CA/San_Francisco.json

response = HTTParty.get("http://api.wunderground.com/api/418ccbe65bea6581/forecast10day/q/NY/New_York.json")



binding.pry