require 'time'
require_relative "parser"

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
		begin
			start
			average
		rescue => error
			#possible handling of multiple errors
			if error.class == 'ZeroDivisionError'
				puts "Error: Total cast members is 0, check if cast information is available."
			end
		end
	end
end
