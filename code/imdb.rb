require_relative "aginator"

class Imdb_Aginator < Aginator
	def initialize(title)
		super()
		@base_url = "http://www.imdb.com"
		@title = title
		@parse_order = ["movie", "cast", "birthdate"]
	end

	def to_s
		"According to IMDB, the average age for the cast of the movie '#{@title}' is #{@age}"
	end

	def sanitize
		new_title = @title.gsub ' ', '+'
		if not new_title.include? @year.to_s
			new_title += "+#{@year.to_s}"
		end
		new_title
	end

	def get_movie
		query = sanitize
		url = "#{@base_url}/find?q=#{query}&s=tt"
		movie_list_html = parse url, ".findList a", true
		href = movie_list_html.attr("href")
		movie_id = href[/tt[0-9]+/]
	end

	def get_cast(id)
		url = "#{@base_url}/title/#{id}/fullcredits"
		cast_tags = parse url, "*[itemprop='actor'] a"
		cast_ids = []
		cast_tags.each do |cast_tag|
			href = cast_tag.attr "href"
			cast_id = href[/nm[0-9]+/]
			cast_ids << cast_id
		end
		cast_ids
	end

	def get_birthdate(ids)
		ids.each do |id|
			url = "#{@base_url}/name/#{id}"
			date_tag = parse url, "time", true
			if date_tag
				date = date_tag.attr "datetime"
				#some pages dont have full dates, which causes errors with the Time object
				if not date[/^0-/]
					date = date.gsub /-0$/, "-1"
					date = date.gsub "-0-", "-1-"
					calculate date
				end
			end
		end
	end
end
