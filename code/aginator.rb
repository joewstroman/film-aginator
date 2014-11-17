#!/usr/bin/env ruby

require 'time'
require 'nokogiri'
require 'open-uri'

class Parser
	def initialize
		@returned_value = nil
	end

	def url_opener(url)
		page = Nokogiri::HTML(open(url))
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

class Aginator < Parser
	def initialize
		super()
		@total_cast = 0
		@total_age = 0
		@age = 0
		@today = Time.new
		@year = "#{@today.year}"
		@movie_id = ""
		@cast_id = ""
		@returned_tags = nil
	end

	def average
		@age = @total_age/@total_cast
	end

	def calculate(birthdate)
		birthdate = Time.parse birthdate
		age = @today.year - birthdate.year
		if @today.month < birthdate.month
			age -= 1
		elsif @today.month == birthdate.month and @today.day < birthdate.day
			age -= 1
		end
		@total_age += age
		@total_cast += 1
	end

	#maybe unnecessary getter method
	def today
		@today
	end

	def aginate
		puts "Currently processing: #{@title}"
		start
		begin
			average
		rescue ZeroDivisionError
			puts "Error: Total cast members is 0, check if cast information is available."
		end
	end
end

class Imdb_Aginator < Aginator
	def initialize(title)
		super()
		@base_url = "http://www.imdb.com"
		@title = title
		@parse_order = ["movie", "cast", "birthdate"]
	end

	def to_s
		"According to IMDB, the average age for the cast of the movie #{@title} is #{@age}"
	end

	def sanitize
		@title.gsub ' ', '+'
		if not @title.include? @year
			@title += "+#{@year}"
		end
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


#setup
puts "Collecting list of movies in theaters"
fp = Fandango_parser.new
fp.start
counter = 0
fp.now_playing.each do |title|
	aginator = Imdb_Aginator.new title
	aginator.aginate
	puts aginator
	counter += 1
	if counter % 5 == 0
		puts "Finished #{counter}/#{fp.now_playing.length} movies"
	end
end
puts "Complete"
