#!/usr/bin/env ruby

require 'Time'

class Parser
	def parse
		#return parsed html
	end

	def url_opener
		#
	end
end

class Aginator < Parser
	def initialize
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
end