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
	end

	def aginate
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

	def today
		@today
	end
end

class IMDB_Aginator < Aginator
	def initialize(title)
		@base_url = "http://www.imdb.com"
		@title = title
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

	#OR

	#send in url and all selectors in a list and just parse in that order
	def parse(url)
		@opener()
	end
end