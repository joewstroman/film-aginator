class Parser
	def initialize
		@returned_value = nil
	end

	def url_opener(url)
		page = Nokogiri::HTML(open('http://en.wikipedia.org/wiki/HTML'))
	end

	#send in url and all selectors in a list and just parse in that order
	def parse(url, selectors, limiter=false)
		page = url_opener url
		if limiter
			page.at_css selectors
		else
			page.css selectors
		end
	end

	def start
		@parse_order.each do |message|
			if @returned_value
				send "get_#{message}", @returned_value
			else
				send "get_#{message}"
			end
		end
		@returned_value = nil
	end
end