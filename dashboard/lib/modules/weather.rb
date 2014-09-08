require "httparty"

module Weather

	def self.validate_wunderground_search(search_term)
  		if search_term.include?(",")
  			location = search_term.split(",")
  			location = location.collect { |item| URI.encode(item) }
  		else
  			false
  		end
  	end

  	def self.get_forecast(array)
  		request = "http://api.wunderground.com/api/418ccbe65bea6581/forecast10day/q/#{array[1]}/#{array[0]}.json"
  		response = HTTParty.get(request)
  	end

  	def self.has_forecast?(array)
  		array.include?("forecast")
  	end


  	def self.construct_weather_post(forecast, day, location, index, id)
  		date = "#{day["date"]["monthname"]} #{day["date"]["day"]}, #{day["date"]["year"]}"
  		{feed_id: id, content: "High: #{day["high"]["fahrenheit"]} Low: #{day["low"]["fahrenheit"]}", context: forecast["forecast"]["txt_forecast"]["forecastday"][index * 2]["fcttext"], time_data: date, url: "http://www.wunderground.com/cgi-bin/findweather/hdfForecast?query=#{location[0]}%2C+#{location[1]}", created_at: Time.now, deleted: false}
  	end


  	def self.seed_weather_posts(feed)
  		location = Weather.validate_wunderground_search(feed.search_term)
  		if location
  			forecast = Weather.get_forecast(location)
  			if Weather.has_forecast?(forecast)
  				forecast["forecast"]["simpleforecast"]["forecastday"][0..9].each_with_index do |day, index|
  					post = Weather.construct_weather_post(forecast, day, location, index, feed.id)
  					Post.create(post)
  				end
  				true
  			else
  				false
  			end
  		else
  			false
  		end
  	end

end



