require "active_record"

class Post < ActiveRecord::Base

	def self.link_to_text(str)
		if str.downcase.include?("http")
			links = str.scan(/http\S+/)
			links.each do |link|
				str = str.gsub(link, "<a href='#{link}' target='_blank'>#{link}</a>")
			end
		end
		str
	end

end