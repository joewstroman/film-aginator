#!/usr/bin/env python

import urllib2
import datetime
import re
#html parser
from bs4 import BeautifulSoup

#constants
IMDB_BASE_URL = "http://www.imdb.com"
FANDANGO_BASE_URL = "http://www.fandango.com"
TODAY = datetime.datetime.now()

class imdb_aginator:
	def __init__(self, title):
		self.total_cast = 0
		self.total_age = 0
		self.title = title
		self.age = 0
		self.date_format = "%Y-%m-%d"
		self.today = datetime.datetime.now()

	def __str__(self):
		return "The average age for the movie %s is %d" % (self.title, self.age) 

	def aginate(self):
		self.age = self.total_age/self.total_cast

	def find_age(self, birthdate):
		birthdate = datetime.datetime.strptime(birthdate, self.date_format)
		age = self.today.year - birthdate.year
		if ((self.today.month, self.today.day) < (birthdate.month, birthdate.day)):
			age -= 1
		return age
		 

def get_cast(movie):
	#find all members of the cast
	#adding the year in case of duplicate movie name/movie reboot
	print 'processing.....'
	url = IMDB_BASE_URL + "/find?q=" + movie + "+" + str(TODAY.year) + "&s=tt"
	imdb_soup = souper(url)
	titles_div = imdb_soup.find(class_="findList")
	movie_link = titles_div.find("a")["href"]
	matches = re.search('tt[0-9]+', movie_link)
	movie_id = matches.group(0)
	url = IMDB_BASE_URL + "/title/" + movie_id + "/fullcredits"
	imdb_soup = souper(url)
	cast_table = imdb_soup.find(class_="cast_list")
	cast_tds = cast_table.find_all("td", itemprop="actor")
	aginator = imdb_aginator(movie)
	for td in cast_tds:
		m = re.search('nm[0-9]+', td.a['href'])
		actor_id = m.group(0)
		url = IMDB_BASE_URL + "/name/" + actor_id
		imdb_soup = souper(url)
		try:
			birthdate = imdb_soup.find('time')['datetime']
			aginator.total_age += aginator.find_age(birthdate)
			aginator.total_cast += 1
		except:
			#skip actor that has no birthday on file
			pass
	aginator.aginate()
	print aginator


def begin():
	fandango_soup = souper("http://www.fandango.com/moviesintheaters")
	movies_ul = fandango_soup.find(id="now_playing_np_div").find('ul')
	num_movies = len(movies_ul)
	counter = 0
	print "Total movies showing in theatres: %d" % (num_movies)
	for li in movies_ul.find_all('li', recursive=False):
		title = li.find(class_="visual-title").text.strip()
		get_cast(title)
		counter += 1
		print "Finished %d/%d movies" % (counter, num_movies)


def souper(url):
	#opens url, and parses the html for searching and extracting
	response = urllib2.urlopen(url)
	page_source = response.read()
	soup = BeautifulSoup(page_source)
	return soup


if __name__ == "__main__":
	begin()
