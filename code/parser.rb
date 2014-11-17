require 'nokogiri'
require 'open-uri'

class Parser
	def initialize
		@returned_value = nil
	end

	def url_opener(url)
		page = Nokogiri::HTML(open(URI::encode(url)))
	end

	#send in url and string of selectors in a list and just parse in that order
	def parse(url, selectors, limiter=false)
		page = url_opener url
		if limiter
			page.at_css selectors
		else
			page.css selectors
		end
	end

	#made so that any parser can have different methods that need to be executed
	#since web site structures can vary in multiple ways
	def start
		@parse_order.each do |message|
			if @returned_value
				@returned_value = send "get_#{message}", @returned_value
			else
				@returned_value = send "get_#{message}"
			end
		end
		@returned_value = nil
	end
end