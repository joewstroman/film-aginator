require_relative "imdb"
require_relative "fandango"

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
