require_relative "parser"

class Fandango_parser < Parser
	def initialize
		@base_url = "http://www.fandango.com"
		@now_playing = []
		@parse_order = ["movies"]
	end

	def get_movies
		url = "#{@base_url}/moviesintheaters"
		title_tags = parse url, "#now_playing_np_div .visual-title"
		title_tags.each do |tag|
			@now_playing << tag.text.strip
		end
		puts "Total movies showing in theatres: #{@now_playing.length}"
	end

	def now_playing
		@now_playing
	end
end