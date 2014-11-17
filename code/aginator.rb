#!/usr/bin/env ruby

require 'time'
require 'nokogiri'
require 'open-uri'

class Parser
	def initialize
		@page = ''
	end

	#override in specific page class in this case imdb_aginator
	def parse; end

	def url_opener(url)
		@page = Nokogiri::HTML(open('http://en.wikipedia.org/wiki/HTML'))
	end
end

class Aginator < Parser
	def initialize
		super()
		@total_cast = 0
		@total_age = 0
		@age = 0
		@today = Time.new
		@movie_id = ""
		@cast_id = ""
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
		@total_age += age
		@total_cast += 1

	#maybe unnecessary getter method
	def today
		@today
	end

	def aginate
		@parse_order.each do |message|
			@send "get_#{message}"
		end
		@average
	end
end

class IMDB_Aginator < Aginator
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
		@title.sub ' ', '+'
	end

	#make method for each type of data being scraped
	#one to get title list of potential movies
	#one for the cast list
	#one to get each individual members age
	#this should be generic enough for any site parser

	def get_movie
		query = @sanitize
		query = "#{query}+#{@today.year}"
		url = "#{@base_url}/find?q=#{query}&s=tt"
		movie_list_html = @parse url, ".findList a", true
		href = movie_list_html.attr("href")
		movie_id = href[/tt[0-9]+/]
	end

	def get_cast(id)
		url = "#{@base_url}/title/#{id}/fullcredits"
		@cast_tags = @parse url, "a[itemprop='url']"
		@cast_tags.each do |cast_tag|
			href = cast_tag.attr("href")
			cast_id = href[/nm[0-9]+/]
			get_birthdate cast_id
		end
	end

	def get_birthdate(id)
		url = "#{@base_url}/name/#{id}"
		date_tag = @parse url, "time", true
		@calculate date_tag.attr "datetime"
	end

	#OR

	#send in url and all selectors in a list and just parse in that order
	def parse(url, selectors, limiter=false)
		@url_opener url
		if limiter
			@page.at_css selectors
		else
			@page.css selectors
		end

	end
end